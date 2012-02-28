class ServerImageGroupsController < ApplicationController
  parent_resources :provider_account
  before_filter :login_required
  require_role  :admin

  # GET /server_image_groups
  # GET /server_image_groups.xml
  def index
    @server_image_groups = parent.server_image_groups

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @server_image_groups }
      format.js
    end
  end

  # GET /server_image_groups/new
  # GET /server_image_groups/new.xml
  def new
    @server_image_group = parent.server_image_groups.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @server_image_group }
      format.js
    end
  end

  # GET /server_image_groups/1/edit
  def edit
    @server_image_group = parent.server_image_groups.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @server_image_group }
      format.js
    end
  end

  # POST /server_image_groups
  # POST /server_image_groups.xml
  def create
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :images,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @server_image_group = parent.server_image_groups.build(params[:server_image_group])

      respond_to do |format|
        if @server_image_group.save
          flash[:notice] = 'ServerImageGroup was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @server_image_group, :status => :created, :location => @server_image_group }
          format.js
        else
          @error_messages = @server_image_group.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "new" }
          format.xml  { render :xml => @server_image_group.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /server_image_groups/1
  # PUT /server_image_groups/1.xml
  def update
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :images,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @server_image_group = ServerImageGroup.find(params[:id])

      respond_to do |format|
        if @server_image_group.update_attributes(params[:server_image_group])
          flash[:notice] = 'ServerImageGroup was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
          format.js
        else
          @error_messages = @server_image_group.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "edit" }
          format.xml  { render :xml => @server_image_group.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # DELETE /server_image_groups/1
  # DELETE /server_image_groups/1.xml
  def destroy
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :images,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    @server_image_group = ServerImageGroup.find(params[:id])
    @server_image_group.destroy

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
      format.js
    end
  end

  def sort
    params[:provider_account_server_image_groups].each_with_index do |id, index|
      ServerImageGroup.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
