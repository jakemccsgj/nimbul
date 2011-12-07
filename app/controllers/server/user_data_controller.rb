require 'erb'
require 'zlib'
require 'md5'

# Support requesting the .sh extension
Mime::Type.register 'text/plain', :sh

class Server::UserDataController < ApplicationController
  USERDATA_PATH     = File.join(RAILS_ROOT, 'app', 'views', 'server', 'user_data')
  SALT = APP_CONFIG['settings']['secret']

  before_filter :login_required, :except => :show
  before_filter(:only => :show) do |controller|
    controller.send(:login_required) unless controller.action_name == 'show' and controller.request.format.sh?
  end

  require_role  :admin, :unless => "params[:id].nil? or current_user.has_server_access?(Server.find(params[:id])) "

  def show
    @server = Server.find(params[:server_id], :include => { :cluster => :provider_account})
    @provider_account = @server.cluster.provider_account
    @server_user_data = @server.generate_user_data

    respond_to do |format|
      format.html {
        # remove password values before rendering
        @server.parameters.each do |p|
          @server_user_data.sub!(p.value.sub("'","\'"),'[FILTERED]') if p.is_protected? and !p.value.blank?
        end

        unless @provider_account.messaging_url.blank?
          @server_user_data.sub!(@provider_account.messaging_url, '[FILTERED]')
        end
        render
      }
      format.json { render :json => @server_user_data.to_json }
      format.sh {
        render :action => 'show.sh.erb' and return if MD5.hexdigest(params[:server_id].to_s + SALT) == params[:auth]
        raise "No auth!"
      }
    end
  end

  def bootstrap server
    server_user_data_url server, :format => :sh, :params => { :auth => MD5.hexdigest(server.id.to_s + SALT) }
  end

  class << self
    def read_template tpl
      File.read(File.join(USERDATA_PATH, tpl))
    end

    def get_erb tpl
      ERB.new(read_template(tpl), nil, "%-").result(binding)
    end
  end
end
