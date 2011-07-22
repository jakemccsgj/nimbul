class StorageTypesController < ApplicationController
  parent_resources :provider
  before_filter :login_required
  require_role  :admin

  # GET /storage_types
  # GET /storage_types.xml
  def index
    @storage_types = parent.storage_types

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @storage_types }
      format.js
    end
  end

  # GET /storage_types/new
  # GET /storage_types/new.xml
  def new
    @storage_type = parent.storage_types.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @storage_type }
      format.js
    end
  end

  # GET /storage_types/1/edit
  def edit
    @storage_type = parent.storage_types.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @storage_type }
      format.js
    end
  end

  # POST /storage_types
  # POST /storage_types.xml
  def create
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :storage_types,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @storage_type = parent.storage_types.build(params[:storage_type])

      respond_to do |format|
        if @storage_type.save
          flash[:notice] = 'StorageType was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @storage_type, :status => :created, :location => @storage_type }
          format.js
        else
          @error_messages = @storage_type.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "new" }
          format.xml  { render :xml => @storage_type.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /storage_types/1
  # PUT /storage_types/1.xml
  def update
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :storage_types,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @storage_type = StorageType.find(params[:id])

      respond_to do |format|
        if @storage_type.update_attributes(params[:storage_type])
          flash[:notice] = 'StorageType was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
          format.js
        else
          @error_messages = @storage_type.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "edit" }
          format.xml  { render :xml => @storage_type.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # DELETE /storage_types/1
  # DELETE /storage_types/1.xml
  def destroy
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :storage_types,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    @storage_type = StorageType.find(params[:id])
    @storage_type.destroy

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
      format.js
    end
  end

  def sort
    params[:provider_storage_types].each_with_index do |id, index|
      StorageType.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
