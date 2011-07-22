class InstanceVmTypesController < ApplicationController
  parent_resources :provider
  before_filter :login_required
  require_role  :admin

  # GET /instance_vm_types
  # GET /instance_vm_types.xml
  def index
    @instance_vm_types = parent.instance_vm_types

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @instance_vm_types }
      format.js
    end
  end

  # GET /instance_vm_types/new
  # GET /instance_vm_types/new.xml
  def new
    @instance_vm_type = parent.instance_vm_types.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @instance_vm_type }
      format.js
    end
  end

  # GET /instance_vm_types/1/edit
  def edit
    @instance_vm_type = parent.instance_vm_types.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @instance_vm_type }
      format.js
    end
  end

  # POST /instance_vm_types
  # POST /instance_vm_types.xml
  def create
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :instance_vm_types,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @instance_vm_type = parent.instance_vm_types.build(params[:instance_vm_type])

      respond_to do |format|
        if @instance_vm_type.save
          flash[:notice] = 'InstanceVmType was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @instance_vm_type, :status => :created, :location => @instance_vm_type }
          format.js
        else
          @error_messages = @instance_vm_type.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "new" }
          format.xml  { render :xml => @instance_vm_type.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /instance_vm_types/1
  # PUT /instance_vm_types/1.xml
  def update
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :instance_vm_types,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @instance_vm_type = InstanceVmType.find(params[:id])

      respond_to do |format|
        if @instance_vm_type.update_attributes(params[:instance_vm_type])
          flash[:notice] = 'InstanceVmType was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
          format.js
        else
          @error_messages = @instance_vm_type.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "edit" }
          format.xml  { render :xml => @instance_vm_type.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # DELETE /instance_vm_types/1
  # DELETE /instance_vm_types/1.xml
  def destroy
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :instance_vm_types,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    @instance_vm_type = InstanceVmType.find(params[:id])
    @instance_vm_type.destroy

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
      format.js
    end
  end

  def sort
    params[:provider_instance_vm_types].each_with_index do |id, index|
      InstanceVmType.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
