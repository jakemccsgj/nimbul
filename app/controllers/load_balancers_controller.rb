class LoadBalancersController < ApplicationController
  parent_resources :provider_account
  before_filter :login_required
  require_role  :admin, :unless => "params[:id].nil? or current_user.has_access?(parent)"

  def index
    parent.refresh(params[:refresh]) if params[:refresh] and parent.respond_to?('refresh')

    search = params[:search]
    options = {
      :page => params[:page],
      :order => params[:sort],
      :filter => params[:filter],
      :include => [:load_balancer_listeners, :health_checks, :zones, {:load_balancer_instance_states => :instance}, {:instances => :zone}],
    }
    @load_balancers  = LoadBalancer.search_by_parent(parent, search, options)

    #@parent_type = parent_type
    #@parent = parent
    respond_to do |format|
      format.html
      format.xml  { render :xml => @load_balancers }
      format.js
    end
  end
  def list
    index
  end

  # GET /load_balancers/new
  # GET /load_balancers/new.xml
  def new
    @load_balancer = parent.load_balancers.build
    @load_balancer.load_balancer_listeners.build({
        :protocol => 'HTTP',
        :load_balancer_port => 80,
        :instance_protocol => 'HTTP',
        :instance_port => 80
      })
    @load_balancer.health_checks.build({
        :target_protocol => 'HTTP',
        :target_port => 80,
        :target_path => '/index.html',
        :timeout => 5,
        :interval => 30,
        :unhealthy_threshold => 2,
        :healthy_threshold => 10
      })
    @clusters = @parent.clusters
    @servers = Server.find_all_by_parent(@parent, {:order => :name})
    @instances = @parent.instances
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @load_balancer }
      format.js
    end
  end

  # GET /load_balancers/1/edit
  def edit
    @load_balancer = parent.load_balancers.find(params[:id], :include => [
        :load_balancer_listeners, :health_checks, :load_balancer_instance_states, :instances
      ]
    )
    @clusters = @parent.clusters
    @servers = Server.find_all_by_parent(@parent, {:order => :name})
    @instances = @parent.instances

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @load_balancer }
      format.js
    end
  end

  # POST /load_balancers
  # POST /load_balancers.xml
  def create
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :load_balancers,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      params[:load_balancer][:zone_ids] ||= []
      if params[:load_balancer][:instance_ids]
        params[:load_balancer][:zone_ids] += Instance.find(params[:load_balancer][:instance_ids]).collect{|i| i.zone_id}
      end
      params[:load_balancer][:zone_ids].uniq
      @load_balancer = parent.load_balancers.build(params[:load_balancer])

      respond_to do |format|
        if ElbAdapter.create_load_balancer(@load_balancer) and @load_balancer.save
          @load_balancer.reload
          p = @parent
          o = @load_balancer
          AuditLog.create_for_parent(
            :parent => p,
            :auditable_id => o.id,
            :auditable_type => o.class.to_s,
            :auditable_name => o.load_balancer_name,
            :author_login => current_user.login,
            :author_id => current_user.id,
            :summary => "created '#{o.load_balancer_name}'",
            :changes => o.tracked_changes,
            :force => false
          )
          flash[:notice] = 'LoadBalancer was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @load_balancer, :status => :created, :location => @load_balancer }
          format.js
        else
          @error_messages = @load_balancer.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "new" }
          format.xml  { render :xml => @load_balancer.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /load_balancers/1
  # PUT /load_balancers/1.xml
  def update
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :load_balancers,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @load_balancer = LoadBalancer.find(params[:id])
      params[:load_balancer][:zone_ids] ||= []
      if params[:load_balancer][:instance_ids]
        params[:load_balancer][:zone_ids] += Instance.find(params[:load_balancer][:instance_ids]).collect{|i| i.zone_id}
      end
      params[:load_balancer][:zone_ids].uniq
      
      respond_to do |format|
        if ElbAdapter.update_load_balancer(@load_balancer, params[:load_balancer]) and @load_balancer.update_attributes(params[:load_balancer])
          p = @parent
          o = @load_balancer
          AuditLog.create_for_parent(
            :parent => p,
            :auditable_id => o.id,
            :auditable_type => o.class.to_s,
            :auditable_name => o.load_balancer_name,
            :author_login => current_user.login,
            :author_id => current_user.id,
            :summary => "updated '#{o.load_balancer_name}'",
            :changes => o.tracked_changes,
            :force => false
          )
          flash[:notice] = 'LoadBalancer was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
          format.js
        else
          @error_messages = @load_balancer.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "edit" }
          format.xml  { render :xml => @load_balancer.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # DELETE /load_balancers/1
  # DELETE /load_balancers/1.xml
  def destroy
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :load_balancers,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    @load_balancer = LoadBalancer.find(params[:id])
    

    respond_to do |format|
      if ElbAdapter.delete_load_balancer(@load_balancer) and @load_balancer.destroy
        p = @parent
        o = @load_balancer
        AuditLog.create_for_parent(
          :parent => p,
          :auditable_id => nil,
          :auditable_type => o.class.to_s,
          :auditable_name => o.load_balancer_name,
          :author_login => current_user.login,
          :author_id => current_user.id,
          :summary => "deleted '#{o.load_balancer_name}'",
          :changes => o.tracked_changes,
          :force => false
        )
        flash[:notice] = 'LoadBalancer was successfully deleted.'
        format.html { redirect_to redirect_url }
        format.xml  { head :ok }
        format.js
      else
        @error_messages = @load_balancer.errors.collect{ |e| e[0].humanize+' - '+e[1] }
        format.html { redirect_to redirect_url }
        format.xml  { render :xml => @load_balancer.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  def sort
    params[:provider_load_balancers].each_with_index do |id, index|
      LoadBalancer.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end

  def update_instances
    if params[:id]
      @load_balancer = parent.load_balancers.find(params[:id])
    else
      @load_balancer = parent.load_balancers.build()
    end
    # updates servers based on cluster selected
    if params[:search].blank?
      if !params[:server_id].blank?
        @server = Server.find(params[:server_id],
          :include => [ [:instances => :load_balancer_instance_states] ]
        )
        @instances = @server.instances
      elsif !params[:cluster_id].blank?
        @cluster = Cluster.find(params[:cluster_id], :include => [
            :servers, [:instances => :load_balancer_instance_states]
          ]
        )
        @servers = @cluster.servers
        @instances = @cluster.instances
      else
        @servers = Server.find_all_by_parent(parent, {:order => :name})
        @instances = parent.instances
      end
    else
      @servers = Server.find_all_by_parent(parent, {:order => :name})
      @instances = parent.instances.select{|i| i.instance_id == params[:search]}
    end

    render :update do |page|
      page.replace_html 'load_balancer_servers', :partial => 'servers' if params[:server_id].blank?
      page.replace_html 'load_balancer_find_instance', :partial => 'find_instance' if params[:search].blank?
      page.replace_html 'load_balancer_available_instances',
        :partial => 'load_balancer_instance_states/instance',
        :locals => { :load_balancer_instance_state => nil },
        :collection => @instances
    end
  end

  def search_instances
    update_instances
  end

  def update_servers
    update_instances
  end
end
