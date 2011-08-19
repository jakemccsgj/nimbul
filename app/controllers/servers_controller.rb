class ServersController < ApplicationController
  parent_resources :user
  before_filter :login_required
  require_role  :admin, :except => [ :index, :list ],
    :unless => "(params[:cluster_id] and current_user.has_cluster_access?(Cluster.find(params[:cluster_id]))) "+
      " or (params[:id] and current_user.has_server_access?(Server.find(params[:id]))) "
  
  def prepare_resources
    @server = Server.find(params[:id], :include => [ :server_profile_revision, :security_groups ])
    @cluster = Cluster.find(@server.cluster_id, :include => [ :cluster_parameters ])
    @provider_account = ProviderAccount.find(@cluster.provider_account_id, :include => [ :volumes, :snapshots, :clusters, :provider_account_parameters])
    @instance_vm_types = @cluster.instance_vm_types
    @server_profile_revision = @server.server_profile_revision
    @server_profile = @server_profile_revision.server_profile if @server_profile_revision
    if @server_profile_revision.instance_vm_type_id.nil?
       @server_images = []
    else
       @instance_vm_type = InstanceVmType.find(@server_profile_revision.instance_vm_type_id, :include => [:cpu_profiles, :storage_types])
       @server_images = ServerImage.find_all_by_provider_account_id_and_cpu_profile_id_and_storage_type_id(@cluster.provider_account_id, @instance_vm_type.cpu_profile_ids, @instance_vm_type.storage_type_ids)
       @server_image = ServerImage.find(@server_profile_revision.server_image_id, :include => [:cpu_profile, :storage_type]) unless @server_profile_revision.server_image_id.blank?
    end
  end
  
  def index
    options = {
      :search => params[:search],
      :page => params[:page],
      :order => params[:sort],
      :filter => params[:filter],
      :include => [ :instances,
        :resource_bundles,
        :default_resource_bundle,
        :server_profile_revision,
        :security_groups,
        :zones,
        :addresses,
        :volumes
      ],
    }

    @servers = Server.search_by_user(current_user, options)
  
    @parent_type = 'user'
    @parent = current_user
    @user = current_user
    respond_to do |format|
      format.html
      format.xml  { render :xml => @servers }
      format.js
    end
  end
  alias :list :index
  
  def show
    prepare_resources
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @server }
      format.js
    end
  end
  
  def edit
    prepare_resources
  end
  
  def update
    @server = Server.find(params[:id])
    @server_profile_revision = @server.server_profile_revision
    @server_profile = @server_profile_revision.server_profile if @server_profile_revision
    @cluster = @server.cluster
        
    redirect_url = server_path(@server, :anchor => params[:anchor])
  
    if params[:cancel_button]
      redirect_to redirect_url
    else
      @provider_account = @cluster.provider_account
      @security_groups = @provider_account.security_groups
      @users = User.find(:all, :order => :login)
  
      # FIXME: This prevents removal of the last security group but, fixes a bug where adding/removing
      # SSH access clears out the security groups.
      unless params[:server].try(:[], :security_group_ids).nil?
        @server.security_groups = (@security_groups & (SecurityGroup.find(params[:server][:security_group_ids])))
      end

      @server.attributes = params[:server]
    
      respond_to do |format|
        if @server.update_attributes(params[:publisher])
          flash[:notice] = 'Server was successfully updated.'
          p = @cluster
          o = @server
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
          format.json { render :json => @server }
        else
          format.html { render :action => 'show', :anchor => params[:anchor] }
          format.xml  { render :xml => @server.errors, :status => :unprocessable_entity }
          format.json { render :json => @server }
        end
      end
  
    end
  end

  def update_server_images
    # updates server_images based on instance_vm_type selected
    @server = Server.find(params[:id], :include => [ :cluster, :server_profile_revision ])
    @server_profile_revision = @server.server_profile_revision
    @cluster = @server.cluster
    @instance_vm_types = @cluster.instance_vm_types
    @instance_vm_type = InstanceVmType.find(params[:instance_vm_type_id],:include => [:cpu_profiles, :storage_types])
    @server_images = ServerImage.find_all_by_provider_account_id_and_cpu_profile_id_and_storage_type_id(@cluster.provider_account_id, @instance_vm_type.cpu_profile_ids, @instance_vm_type.storage_type_ids)
    @server_image = ServerImage.find(@server_profile_revision.server_image_id, :include => [:cpu_profile, :storage_type]) unless @server_profile_revision.server_image_id.blank?
    @server_image = nil unless @server_images.include?(@server_image)

    render :update do |page|
      page.replace_html 'instance_vm_type_info', :partial => 'instance_vm_type'
      page.replace_html 'server_images', :partial => 'server_images'
    end
  end

  def update_server_image_info
    # updates server image info based on server_image selected
    @server_image = ServerImage.find(params[:server_image_id], :include => [ :cpu_profile, :storage_type])

    render :update do |page|
      page.replace_html 'server_image_info', :partial => 'server_image_info'
    end 
  end
end
