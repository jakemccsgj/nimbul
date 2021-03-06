# Be sure to restart your server when you modify this file

# for more info, see: http://ozmm.org/posts/try.html
#
# dirty little helper method that protects us from nils
#
# used like so:
#
#   Person.find_by_email(nonexistant_email).try(:name)
#
#   This will return nil if find didn't find the record or
#   the name if it found the record

class Object
  def try(method, *args)
    send method, *args if respond_to? method
  end
end

class ServiceWithoutActiveInstance < Exception
end

ENV['RAILS_ENV'] ||= 'development'
#ENV['GEM_PATH'] = "/usr/lib/ruby/gems/1.8/gems:#{ENV['GEM_PATH']}"
#Gem.clear_paths

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

#Load application and environment specific constants
raw_config = File.read(RAILS_ROOT + "/config/config.yml")
APP_CONFIG = YAML.load(raw_config)[RAILS_ENV]

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.
  #require 'action_mailer/ar_mailer'
  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # for daemons we only need access to active record and
  # action mailer (the latter less so than the former)
  if ENV['DAEMON_SCRIPTLET']
    config.frameworks = [ :active_record, :action_mailer ]
  end

  config.time_zone = 'Eastern Time (US & Canada)'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :key => APP_CONFIG['settings']['session_key'],
    :secret  => APP_CONFIG['settings']['secret']
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer,
                                   :user_key_observer,
                                   :server_user_access_observer,
                                   :instance_observer,
                                   :provider_account_observer

  # Helper type for select boxes
  LabelValue = Struct.new(:label,:value)

  # Helper type for select boxes with groups
  GroupLabelValue = Struct.new(:group, :label, :value)

  # Helper type for select boxes with groups and filter
  GroupLabelValueFilter = Struct.new(:group, :label, :value, :filter)

  # Helper type to JSON Error handling
  ModelError = Struct.new(:model,:error)

  # Helper type for Startup Scripts
  StartupScript = Struct.new(:name,:body)

  #Constant values
  EC2_SERVER_USERS                        = [ 'root', 'dev', 'logpoll' ]
  PUBLISH_EVERY_VALUES                    = [ 0, 10, 20, 30, 60, 120, 300, 600, 1800, 3600 ]
  IN_MESSAGE_STATES                       = [ 'new', 'processed' ]
  OUT_MESSAGE_STATES                      = [ 'pending', 'sent' ]
  PROTOCOLS_LC                            = [ 'tcp', 'udp', 'icmp' ]
  PROTOCOLS                               = PROTOCOLS_LC.map{ |p| LabelValue.new(p, p.upcase) }
  VOLUME_CLASSES                          = [ 'Volume', 'Snapshot', 'AnotherServer' ]
  RUN_EVERY_UNITS                         = [ 'minutes', 'hours', 'days', 'weeks' ]
  AS_TRIGGER_MEASURE_NAMES                = {
    'CPUUtilization'  => [ 'Percent' ],
    'NetworkIn'       => [ 'Bytes', 'Bytes/Second', 'Bits', 'Bits/Second' ],
    'NetworkOut'      => [ 'Bytes', 'Bytes/Second', 'Bits', 'Bits/Second' ],
    'DiskWriteOps'    => [ 'Count', 'Count/Second' ],
    'DiskReadOps'     => [ 'Count', 'Count/Second' ],
    'DiskWriteBytes'  => ['Bytes', 'Bytes/Second', 'Bits', 'Bits/Second' ],
    'DiskReadBytes'   => [ 'Bytes', 'Bytes/Second', 'Bits','Bits/Second' ],
  }
  AS_TRIGGER_STATISTICS                   = [ 'Average','Minimum','Maximum','Sum' ]
  AS_TRIGGER_PERIOD_UNITS                 = [ 'minutes', 'hours', 'days' ]
  AS_TRIGGER_BREACH_DURATION_UNITS        = [ 'minutes', 'hours', 'days' ]
  AS_TRIGGER_THRESHOLD_ACTIONS            = [ 'increase', 'decrease' ]
  AS_TRIGGER_BREACH_SCALE_INCREMENT_UNITS = [ '%', 'instances' ]
  ELB_TARGET_PROTOCOL_NAMES = [ 'HTTP', 'TCP', 'HTTPS', 'SSL'  ]
  ELB_TARGET_PROTOCOL_WITH_PATH_NAMES = [ 'HTTP', 'HTTPS' ]
  ELB_THRESHOLD_VALUES = [ 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
  SERVER_VOLUME_MOUNT_TYPES_ARRAY = [ 'Mount Volume Mount Type', 'Restore Snapshot Mount Type', 'Restore Latest Snapshot Mount Type' ]
  SERVER_VOLUME_MOUNT_TYPES = SERVER_VOLUME_MOUNT_TYPES_ARRAY.map{ |t| LabelValue.new(t.gsub('Mount Type',''), t.gsub(' ','')) }

  PER_TIME_UNITS                          = [ 'hour', 'day', 'month', '1 year', '3 years' ]

  STARTUP_SCRIPT_PACKAGERS = [
    { :name => 'nimbul', :description => "Combines Provider Account's, Cluster's and Server's Variables and Startup Scripts. Minifies and compresses to create the final User Data. The resulting User Data requires an NYTd-built AMI to run successfully." },
    { :name => 'none', :description => 'Uses Server Startup Script as User Data. Provider Account and Cluster scripts are ignored. Useful for Public / Windows AMIs.' }
  ]

  INSTANCE_KIND_IO_PERFORMANCES = [ 'Low', 'Moderate', 'High' ]

  PKI_CONSOLE_ID = 'console'

  PKI_CONSOLE_BASE  = RAILS_ROOT + '/pki'
  PKI_INSTANCE_BASE = '/var/nyt/gnupg'

  LDNS_REGISTRY_PATH = RAILS_ROOT + '/tmp/cache'
  LDNS_HOSTFILE_PATH = RAILS_ROOT + '/tmp/cache/ldns-hosts'
end

CACHE = MemCache.new('memcached.lcl')
