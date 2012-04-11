require 'daemon_controller'
require 'active_support'
require 'ostruct'
require 'drb'
require 'logger'

##
# = Purpose
#
# Due to the sensitive nature of some information that the Nimbul application handles,
# it is necessary to store the AWS account access keys in a memory only keystore.  This
# was hadled previously using a SysVIPC based solution, using SHMEM.  This new implementation
# will use the STDLIB module, DrB.  This module allows for "distributed ruby", which we will
# use to distribute the key objects across processes.  It is a trivially simple matter of
# opening a firewall port to allow Nimbul to be running across multiple instances, sharing
# data objects and calling methods on each other.
#

class TransientKeyStore
  at_exit { self.class.stop_service rescue nil; exit }

  private
  attr_accessor :uri, :env, :logger, :drb, :data

  SERVER_ADDR    = '127.0.0.1'
  SERVER_PORT    = '55534'
  DEFAULT_URI    = "druby://#{SERVER_ADDR}:#{SERVER_PORT}"
  DEFAULT_LOGGER = Logger.new($stderr)
  DEFAULT_LOGGER.level = Logger::WARN
  DEFAULT_ENVIRONMENTS = [ :development, :testing, :production ]
  DEFAULT_TIMEOUT      = 2 #seconds

  public

  def initialize *opts
    @controller = DaemonController.new(
      :identifier    => 'Transient Key Store server',
      :start_command => File.join(RAILS_ROOT, 'lib/transient_key_store_controller.rb start'),
      :ping_command  => [:tcp, SERVER_ADDR, SERVER_PORT],
      :pid_file      => File.join(RAILS_ROOT, 'log/transient_key_store.pid'),
      :log_file      => File.join(RAILS_ROOT, 'log/transient_key_store.log')
      #:before_start  => method(:before_start)
    )
    @timeout = DEFAULT_TIMEOUT

    begin
      opts = opts.first.to_h
    rescue
      env, opts = opts[0], opts[1] || {}
      opts.merge! :env => env
    end

    default_options = {:env => DEFAULT_ENVIRONMENTS.first, :uri => DEFAULT_URI, :logger => DEFAULT_LOGGER}
    opts = default_options.merge(opts)
    # Set up attributes
    opts.each_pair { |opt, val|
      self.send "#{opt.to_s}=".to_sym, val
    }
    DRb.start_service
  end
  alias :instance :initialize

  ##  Read the key (notice the aliases)
  def read key
    logger.debug "Getting key #{key}"
    keystore.send(key.to_sym)
  end
  alias :get :read
  alias :[] :read

  ##  Write the key (notice the aliases)
  def write key, value
    logger.debug "Sending #{key}, #{value} from write method"
    keystore.send("#{key.to_s}=".to_sym, value)
    keystore.keys.add(key.to_sym) unless keystore.keys.include? key.to_sym
  end
  alias :put :write
  alias :set :write
  alias :[]= :write

  private

  # returns the "keystore" DRbObject
  def keystore
    #return @drb if @drb
    @drb_keystore ||= @controller.connect do
        begin
          #  Drb has deadlocked on me - ugh
          Timeout.timeout(@timeout) {
            logger.debug "Getting keystore for #{env}"
            @drb ||= DRbObject.new_with_uri uri
            logger.debug "#{@drb.__drburi} - #{@drb.__drbref}\n"
            @drb.send(env.to_s)
          }
        rescue Timeout::Error
          logger.debug("Timeout in keystore!")
          retry
        end
    end
    logger.debug "#{@drb_keystore.to_s}: #{@drb_keystore.hash} #{@drb_keystore.object_id}"
    @drb_keystore
  end

  def method_missing meth, *args, &block
    begin
      if keys.include? meth.to_sym
        self.class.send(:define_method, meth.to_sym) { get meth.to_sym }
      else
        raise
      end
      send meth, *args, &block
    rescue
      raise
    end
  end

  public

  def keys
    keystore.keys.to_a
  end

  ##
  # Run a server instance
  #
  class << self
    ##  Start the service, and wait
    def run_server uri=DEFAULT_URI, environments=DEFAULT_ENVIRONMENTS, logger=DEFAULT_LOGGER
      trap("INT") { self.stop_server; exit }
      services = KeyStore.new()
      environments.each { |env|
        services.send "#{env}=".to_sym, KeyStore.new( :environment => env )
      }
      DRb.start_service uri, services
      logger.info "Server started @ #{DRb.uri}"
      DRb.thread.join
    end

    ##  Cleanly kill it
    def stop_server logger=DEFAULT_LOGGER
      logger.debug "Stopping DRb service"
      DRb.stop_service
      logger.debug "Joining DRb thread"
      DRb.thread.join rescue nil
    end

    def instance opts
      new opts
    end

    # Initialize the object from YAML, and then have it store it's data to the keystore
    def from_yaml env, str
      inst = self.instance env
      YAML::load(str).each_pair do |k, v|
        inst[k] = v
      end
      inst
    end

    def to_yaml env
      keys = Hash.new
      inst = self.instance(env)
      inst.keys.each do |k|
        keys[k] = inst[k]
      end
      YAML::dump(keys)
    end
  end
end

class KeyStore < OpenStruct
  include DRbUndumped
  attr_accessor :keys
  def initialize *args
    @keys = Set.new.extend(DRbUndumped)
    super
  end
end
