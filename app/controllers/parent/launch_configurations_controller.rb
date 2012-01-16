class Parent::LaunchConfigurationsController < ApplicationController
  parent_resources :provider_account, :cluster
  before_filter :login_required
  require_role  :admin, :unless => "current_user.has_access?(parent)"

  def load_configs
    search = params[:search]
    options = {
      :conditions => [ 'provider_account_id = ?', @provider_account.id ],
      :page => params[:page],
      :order => params[:sort],
      :include => [ :server_image, :provider_account, :auto_scaling_groups ],
    }
		
    @launch_configurations = LaunchConfiguration.search(search, options)
  end

	def index
    parent.refresh(params[:refresh]) if params[:refresh] and parent.respond_to?('refresh')

    search = params[:search]
    options ={
      :page => params[:launch_configuration_page],
      :order => params[:sort],
      :include => [ :server, :server_image, :provider_account, :auto_scaling_groups, :server_profile_revision, :instance_vm_type ],
    }
    @launch_configurations  = LaunchConfiguration.search_by_parent(parent, search, options)

    #@parent_type = parent_type
    #@parent = parent
    respond_to do |format|
      format.html
      format.xml  { render :xml => @launch_configurations }
      format.js
    end
  end
  def list
    index
  end

  # GET /launch_configurations/1
	def show
		@launch_configuration = parent.launch_configurations.find(params[:id], :include => [ :security_groups, :block_device_mappings ])
		
		respond_to do |format|
			format.html # show.html.erb
			format.json { render :json => @launch_configuration }
			format.xml  { render :xml => @launch_configuration }
		end
	end

  # GET /launch_configurations/1/edit
	def edit
		@launch_configuration = parent.launch_configurations.find(params[:id], :include => [ :security_groups, :block_device_mappings ])
		@cluster = @launch_configuration.try(:server, :cluster)

    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :auto_scaling,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)
    
		return redirect_to(redirect_url) if @launch_configuration.locked?

		respond_to do |format|
			format.html # edit.html.erb
		end
	end

  def update
		@launch_configuration = parent.launch_configurations.find(params[:id], :include => [ :security_groups, :block_device_mappings ])

    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :auto_scaling,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

		return redirect_to(redirect_url) if @launch_configuration.active?

		attrs = lc_params = params[:launch_configuration]
		if params[:lc_based_on] == 'existing'
			attrs = get_server_attributes(lc_params[:server_id], lc_params[:server_profile_revision_id]).merge!(lc_params)
		end

		@launch_configuration.attributes = attrs

    respond_to do |format|
			if @launch_configuration.try(:save)
				flash[:notice] = 'Launch Configuration was successfully updated.'
        p = parent
				o = @launch_configuration
				AuditLog.create_for_parent(
					:parent => p,
					:auditable_id => o.id,
					:auditable_type => o.class.to_s,
					:auditable_name => o.name,
					:author_login => current_user.login,
					:author_id => current_user.id,
					:summary => "updated '#{o.name}'",
					:changes => o.tracked_changes,
					:force => false
				)
				format.html { redirect_to redirect_url }
				format.xml  { render :xml => @launch_configuration, :status => :updated, :location => @launch_configuration }
			else
				flash[:error] = 'Failed to update a Launch Configuration: ' + (@launch_configuration.try(:cloud_message) || 'unknown problem')
        format.html { render :action => :edit }
        format.xml  { render :xml => @launch_configuration.errors, :status => :unprocessable_entity }
      end
		end
	end

  def destroy
    @launch_configuration = parent.launch_configurations.find(params[:id], :include => [ :security_groups, :block_device_mappings ])

    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :auto_scaling,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

		return redirect_to(redirect_url) if @launch_configuration.active?

		@error_messages = []
    @launch_configuration.destroy
		@error_messages += @launch_configuration.errors.collect{ |attr,msg| "#{attr.humanize} - #{msg}" }

    respond_to do |format|
			if @error_messages.empty?
				p = parent
				o = @launch_configuration
				AuditLog.create_for_parent(
					:parent => p,
					:auditable_id => nil,
					:auditable_type => o.class.to_s,
					:auditable_name => o.name,
					:author_login => current_user.login,
					:author_id => current_user.id,
					:summary => "deleted '#{o.name}'",
					:changes => o.tracked_changes,
					:force => true
				)
			else
				flash[:error] = @error_messages.join('<br/>')
			end
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
      format.js
    end
  end

	def activate
    @launch_configuration = parent.launch_configurations.find(params[:id])

		options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :auto_scaling,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)
    
		@error_messages = []
		@launch_configuration.activate!
		@error_messages += @launch_configuration.errors.collect{ |attr,msg| "#{attr.humanize} - #{msg}" }

		load_configs

		respond_to do |format|
			if @error_messages.empty?
        p = parent
				o = @launch_configuration
				AuditLog.create_for_parent(
					:parent => p,
					:auditable_id => o.id,
					:auditable_type => o.class.to_s,
					:auditable_name => o.name,
					:author_login => current_user.login,
					:author_id => current_user.id,
					:summary => "activated '#{o.name}'",
					:changes => o.tracked_changes,
					:force => false
				)
			else
				flash[:error] = @error_messages.join('<br/>')
			end
			format.html { redirect_to redirect_url }
			format.js
		end
	end

	def disable
		@launch_configuration = LaunchConfiguration.find(params[:id])

    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :auto_scaling,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)
    
		@error_messages = []
		@launch_configuration.disable!
		@error_messages += @launch_configuration.errors.collect{ |attr,msg| "#{attr.humanize} - #{msg}" }
    
		load_configs

		respond_to do |format|
			if @error_messages.empty?
				p = parent
				o = @launch_configuration
				AuditLog.create_for_parent(
					:parent => p,
					:auditable_id => o.id,
					:auditable_type => o.class.to_s,
					:auditable_name => o.name,
					:author_login => current_user.login,
					:author_id => current_user.id,
					:summary => "disabled '#{o.name}'",
					:changes => o.tracked_changes,
					:force => false
				)
			else
				flash[:error] = @error_messages.join('<br/>')
			end
			format.html { redirect_to redirect_url }
			format.js
		end
	end

	def associate
		@launch_configuration = LaunchConfiguration.find(params[:id])
		
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :auto_scaling,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    return redirect_to(redirect_url) if @launch_configuration.locked?

		lc_params = params[:launch_configuration]
		@launch_configuration.attributes = get_server_attributes(lc_params[:server_id]).merge!(lc_params)

		respond_to do |format|
			if @launch_configuration.try :save
				p = parent
				o = @launch_configuration
				AuditLog.create_for_parent(
					:parent => p,
					:auditable_id => o.id,
					:auditable_type => o.class.to_s,
					:auditable_name => o.name,
					:author_login => current_user.login,
					:author_id => current_user.id,
					:summary => "associated '#{o.name}' with server [#{lc_params[:server_id]}]",
					:changes => o.tracked_changes,
					:force => false
				)
				format.html { redirect_to redirect_url }
				format.json { render :json => @launch_configuration }
				format.js
			else
				flash[:error] = 'Failed to associate to server: ' + (@launch_configuration.try(:cloud_message) || 'unknown problem')
			end
		end
	end
end
