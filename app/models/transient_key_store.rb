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
  attr_accessor :uri, :env, :logger, :drb

  DEFAULT_URI    = 'druby://localhost:55534'
  DEFAULT_LOGGER = Logger.new($stderr)
  DEFAULT_LOGGER.level = Logger::WARN
  DEFAULT_ENVIRONMENTS = [ :development, :testing, :production ]

  public

  def initialize *opts
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
    logger.debug "Getting keystore for #{env}"
    @drb = DRbObject.new_with_uri uri
    logger.debug "#{@drb.__drburi} - #{@drb.__drbref}\n"
    obj = @drb.send(env.to_s)
    logger.debug "#{obj.to_s}: #{obj.hash} #{obj.object_id}"
    obj
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
    def from_yaml str
      ks = self.instance ENV['RAILS_ENV']
      YAML::load(str).instance_eval { @data }.each_pair do |key, val|
        ks.set key, val
      end
      ks
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
