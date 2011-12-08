require 'erb'

# Class holding user-data info
class ServerUserData
  attr_accessor :server, :startup_scripts, :cloudrc
  USERDATA_PATH     = File.join(RAILS_ROOT, 'app', 'views', 'server', 'user_data')
  LOADER_TEMPLATE   = 'loader'
  CLOUDRC_TEMPLATE  = 'cloudrc.erb'
  PAYLOAD_TEMPLATE  = 'generate.erb'
  EMISSARY_TEMPLATE = 'emissary.erb'

  def initialize(server = nil)
      @server = server
      @cloudrc = nil
      @startup_scripts = nil
  end

  def parameters
    @server.parameters
  end

  def provider_account
    @server.cluster.provider_account
  end

  def cluster
    @server.cluster
  end

  def startup_scripts
    @startup_scripts ||= [
      StartupScript.new('account_script', @server.cluster.provider_account.startup_script || ''),
      StartupScript.new('cluster_script', @server.cluster.startup_script || ''),
      StartupScript.new('server_script', @server.startup_script || '')
    ]
  end

  def cloudrc_config
    @user_data = self
    @cloudrc ||= self.class.template(:cloudrc).result binding
  end

  def emissary_config
  end

  def get_loader
    @emissary_config = tpl.result binding()

    @instance_users = server_data.cluster.instance_users
    @instance_users = @instance_users.merge(server_data.server.server_users)
    @user_data = server_data
    @instance_users.find do |instance_user, users|
      @user_home = instance_user == 'root' ? '/root' : File.join('home', instance_user)
      @instance_user = instance_user
    end
    @emissary_config = get_erb(EMISSARY_TEMPLATE)
    payload = get_erb(PAYLOAD_TEMPLATE)
  end

  class << self
    def template which
      tpl = File.read( File.join(USERDATA_PATH, const_get(which.to_s.upcase + '_TEMPLATE') ) )
      ERB.new(tpl, 0, '-')
    end
  end
end
