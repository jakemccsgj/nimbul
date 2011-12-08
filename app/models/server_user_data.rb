require 'erb'

# Class holding user-data info
class ServerUserData
  attr_accessor :server, :startup_scripts, :cloudrc, :emissary_config
  USERDATA_PATH     = File.join(RAILS_ROOT, 'app', 'views', 'server', 'user_data')
  LOADER_TEMPLATE   = 'loader.erb'
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
    @user_data = self
    @emissary_config ||= self.class.template(:emissary).result binding
  end

  def get_payload
    @emissary_config = emissary_config

    @instance_users = cluster.instance_users.merge(server.server_users)
    @user_data = self
    @instance_users.find do |instance_user, users|
      @user_home = instance_user == 'root' ? '/root' : File.join('home', instance_user)
      @instance_user = instance_user
    end

    script = self.class.template(:payload).result binding
  end

  def get_loader compress=false
    script = get_payload

    if compress
      loader = File.read(File.join(USERDATA_PATH, LOADER_TEMPLATE))
      StringIO.open(loader, 'ab') do |f|
        gz = Zlib::GzipWriter.new(f)
        gz.write script
        gz.close
      end
      script = loader
    end
    script
  end

  class << self
    def template which
      tpl = File.read( File.join(USERDATA_PATH, const_get(which.to_s.upcase + '_TEMPLATE') ) )
      ERB.new(tpl, 0, '-')
    end
  end
end
