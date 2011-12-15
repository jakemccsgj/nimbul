require 'drb'
require 'time'
require 'rinda/ring'
require 'rinda/tuplespace'

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
  attr_accessor :environment

  private
  attr :server_pid, :provider_pid

  public
  ##
  # [env] Initialize the KeyStore to this environment (RAILS_ENV)
  def initialize env
    @environment = env.to_sym
    get_ring_server
  end
  alias :instance :initialize

  def read key, all=false
    method = all ? :read_all : :read
    tuple = [key.to_sym, nil]
    get_ring_server.send(method, tuple)[1]
  end

  def write key, value
    ring_server.write([key.to_sym, value])
  end

  private
  ##
  # Run a server instance
  #
  def run_server
    Process.fork {
      DRb.start_service
      @server = Rinda::RingServer.new Rinda::TupleSpace.new
      DRb.thread.join
    }
  end

#  ##
#  # Set up the keystore service provider
#  def register_keystore
#    Process.fork {
#      DRb.start_service
#      provider = Rinda::RingProvider.new(
#        ('KeyStore' + @environment.to_s.capitalize).to_sym,
#        Rinda::RingFinger.primary,
#        "Memory based keystore for the #{@environment} environment"
#      )
#
#      provider.provide
#      DRb.thread.join
#    }
#  end

  ##
  # Find our ring server.  Will start a fresh one if one is not available.
  def get_ring_server
    DRb.start_service
    begin
      Rinda::RingFinger.primary
    rescue RuntimeError => m
      if m.to_s == 'RingNotFound'
        Process.detach run_server
        sleep 2
        #Process.detach register_keystore
        get_ring_server
      else
        raise
      end
    end
  end
  alias :ring_server :get_ring_server
end

ks = TransientKeyStore.new ENV['RAILS_ENV']

sleep 3
if ARGV[0] == 'write'
  while true
    ks.write :test, Time.now
    sleep 0.1
  end
else
  while true
    puts ks.read(:test)
    sleep 0.2
  end
end
