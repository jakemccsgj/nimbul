class Parent::AutoScalingGroupsController < ApplicationController
  parent_resources :provider_account, :cluster
  before_filter :login_required
  require_role  :admin, :unless => "current_user.has_access?(parent)"

  def index
    parent.refresh(params[:refresh]) if params[:refresh] and parent.respond_to?('refresh')

    search = params[:search]
    options ={
      :page => params[:auto_scaling_group_page],
      :order => params[:sort]
    }
    @auto_scaling_groups  = AutoScalingGroup.search_by_parent(parent, search, options)

    #@parent_type = parent_type
    #@parent = parent
    respond_to do |format|
      format.html
      format.xml  { render :xml => @auto_scaling_groups }
      format.js
    end
  end
  def list
    index
  end

  # GET /auto_scaling_groups/1
	def show
		@auto_scaling_group = parent.auto_scaling_groups.find(params[:id])
		
		respond_to do |format|
			format.html # show.html.erb
			format.json { render :json => @auto_scaling_group }
			format.xml  { render :xml => @auto_scaling_group }
		end
	end

  # GET /auto_scaling_groups/1/edit
	def edit
		@auto_scaling_group = parent.auto_scaling_groups.find(params[:id])
		@cluster = @auto_scaling_group.try(:server, :cluster)

    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :auto_scaling,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)
    
		return redirect_to(redirect_url) if @auto_scaling_group.locked?

		respond_to do |format|
			format.html # edit.html.erb
		end
	end

  def update
		@auto_scaling_group = parent.auto_scaling_groups.find(params[:id], :include => :provider_account)

    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :auto_scaling,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)
    
		asg_params = params[:auto_scaling_group]
		asg_params.try :each do |k,v|
			asg_params[k] = v.chomp
		end

		@auto_scaling_group.attributes = asg_params

    @error_messages = []
    respond_to do |format|
			if @auto_scaling_group.update_attributes(asg_params) and @auto_scaling_group.update_cloud
				flash[:notice] = 'Group was successfully updated.'
        p = parent
				o = @auto_scaling_group
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
				format.xml  { head :ok }
				format.json { render :json => @auto_scaling_group }
				format.js
			else
        @error_messages = @auto_scaling_group.errors.collect{|attr,msg| "#{attr.humanize} - #{msg}"}
				flash[:error] = @error_messages.join('<br/>')
				format.html { redirect_to redirect_url }
				format.xml  { render :xml => @auto_scaling_group.errors, :status => :unprocessable_entity }
				format.json { render :json => @auto_scaling_group, :status => :unprocessable_entity }
				format.js
			end
		end
	end

	def destroy
		@auto_scaling_group = parent.auto_scaling_groups.find(params[:id], :include => :provider_account)

    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :auto_scaling,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)
    
		@error_messages = []
    @auto_scaling_group.destroy
		@error_messages += @auto_scaling_group.errors.collect{ |attr,msg| "#{attr.humanize} - #{msg}" }

    respond_to do |format|
			if @error_messages.empty?
				p = parent
				o = @auto_scaling_group
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

	def disable
		@auto_scaling_group = parent.auto_scaling_groups.find(params[:id], :include => :provider_account)

    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :auto_scaling,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

		@error_messages = []
		@auto_scaling_group.disable!
		@error_messages += @auto_scaling_group.errors.collect{ |attr,msg| "#{attr.humanize} - #{msg}" }

		respond_to do |format|
			if @error_messages.empty?
				p = parent
				o = @auto_scaling_group
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

	def activate
		@auto_scaling_group = parent.auto_scaling_groups.find(params[:id], :include => :provider_account)

    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :auto_scaling,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

		@error_messages = []
		unless @auto_scaling_group.activate!
			@error_messages += @auto_scaling_group.errors.collect{ |attr,msg| "#{attr.humanize} - #{msg}" }
			@error_messages += @auto_scaling_group.launch_configuration.errors.collect{ |attr,msg| "Launch Configuration: #{attr.humanize} - #{msg}" } unless @auto_scaling_group.launch_configuration.errors.empty?
			@auto_scaling_group.auto_scaling_triggers.each do |trigger|
				@error_messages += trigger.errors.collect{ |attr,msg| "Trigger '#{trigger.name}': #{attr.humanize} - #{msg}" } unless trigger.errors.empty?
			end
		end

		respond_to do |format|
			if @error_messages.empty?
        p = parent
				o = @auto_scaling_group
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
end
