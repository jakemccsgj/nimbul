class InstancesController < ApplicationController
  parent_resources :user
  before_filter :login_required
  require_role  :admin, :except => [ :index, :list ],
    :unless => "current_user.has_instance_access?(Instance.find(params[:id])) "

  def index
    search = params[:search]
    options = {
      :page => params[:page],
      :order => params[:sort],
      :filter => params[:filter],
      :include => [ :zone, :server, :user, :security_groups, :provider_account ],
    }
    @instances = Instance.search_by_user(current_user, search, options)

    @parent_type = 'user'
    @parent = current_user
    @user = current_user
    respond_to do |format|
      format.html
      format.xml  { render :xml => @instances }
      format.js
    end
  end
  def list
    index
  end

  def prepare_resources
    @instance = Instance.find(params[:id])
    @provider_account = ProviderAccount.find(@instance.provider_account_id, :include => [ :security_groups, :addresses, :volumes, :snapshots ])
    @users = User.find(:all, :order => :login)
    @security_groups = @provider_account.security_groups
    @leases = DnsLease.find_all_by_instance_id(@instance.id)
  end

  # GET /instances/1
  def show
    self.prepare_resources

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @instance }
      format.json { render :json => @instance }
      format.js
    end
  end

  def update
    @instance = Instance.find(params[:id])
    @provider_account = @instance.provider_account
    @security_groups = @provider_account.security_groups
    @users = User.find(:all, :order => :login)

    @instance.attributes = params[:instance]
    respond_to do |format|
      if @instance.save
        @instance.reload
        flash[:notice] = 'Instance was successfully updated.'
        format.html { render :action => "edit" }
        format.xml  { head :ok }
        format.json { render :json => @instance }
        format.js
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @instance.errors, :status => :unprocessable_entity }
        format.json { render :json => @instance }
        format.js
      end
    end
  end
    
  #  POST /instances/:id/reboot
  def reboot
    @instance = Instance.find(params[:id])
    @error_message = "The Instance is Locked. Unlock to reboot." if @instance.is_locked?
        
    respond_to do |format|
      if @error_message.blank? and @instance.reboot!
        flash[:notice] = "Initiated reboot for Instance #{@instance.instance_id}"
        format.html { render :action => "show" }
        format.xml  { head :ok }
        format.js
      else
        @error_message ||= "Failed to Reboot the Instance: #{@instance.status_message}"
        format.html { render :action => "show" }
        format.xml  { render :xml => @instance.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  #  POST /instances/:id/terminate
  def terminate
    @instance = Instance.find(params[:id])
    @error_messages = []
    @error_messages << "The instance is locked. Unlock to terminate." if @instance.is_locked?
        
    respond_to do |format|
      if @error_messages.empty? and @instance.terminate!
        flash[:notice] = "Terminating instance #{@instance.instance_id}"
        format.html { render :action => "show" }
        format.xml  { head :ok }
        format.js
      else
        @error_messages << "Failed to terminate the instance: #{@instance.status_message}"
        format.html { render :action => "show" }
        format.xml  { render :xml => @instance.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  #  POST /instances/:id/stop
  def stop
    @instance = Instance.find(params[:id])
    @error_messages = []
    @error_messages << "The instance is locked. Unlock to terminate." if @instance.is_locked?
        
    respond_to do |format|
      if @error_messages.empty? and @instance.stop!
        flash[:notice] = "Stopping instance #{@instance.instance_id}"
        format.html { render :action => "show" }
        format.xml  { head :ok }
        format.js
      else
        @error_messages << "Failed to stop the instance: #{@instance.status_message}"
        format.html { render :action => "show" }
        format.xml  { render :xml => @instance.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  #  POST /instances/:id/start
  def start
    @instance = Instance.find(params[:id])
    @error_messages = []
        
    respond_to do |format|
      if @error_messages.empty? and @instance.start!
        flash[:notice] = "Starting instance #{@instance.instance_id}"
        format.html { render :action => "show" }
        format.xml  { head :ok }
        format.js
      else
        @error_messages << "Failed to start the instance: #{@instance.status_message}"
        format.html { render :action => "show" }
        format.xml  { render :xml => @instance.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end
end
