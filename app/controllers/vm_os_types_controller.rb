class VmOsTypesController < ApplicationController
  parent_resources :provider
  before_filter :login_required
  require_role  :admin

  # GET /vm_os_types
  # GET /vm_os_types.xml
  def index
    @vm_os_types = parent.vm_os_types

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @vm_os_types }
      format.js
    end
  end

  # GET /vm_os_types/new
  # GET /vm_os_types/new.xml
  def new
    @vm_os_type = parent.vm_os_types.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @vm_os_type }
      format.js
    end
  end

  # GET /vm_os_types/1/edit
  def edit
    @vm_os_type = parent.vm_os_types.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @vm_os_type }
      format.js
    end
  end

  # POST /vm_os_types
  # POST /vm_os_types.xml
  def create
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :vm_os_types,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @vm_os_type = parent.vm_os_types.build(params[:vm_os_type])

      respond_to do |format|
        if @vm_os_type.save
          flash[:notice] = 'VmOsType was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @vm_os_type, :status => :created, :location => @vm_os_type }
          format.js
        else
          @error_messages = @vm_os_type.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "new" }
          format.xml  { render :xml => @vm_os_type.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /vm_os_types/1
  # PUT /vm_os_types/1.xml
  def update
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :vm_os_types,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @vm_os_type = VmOsType.find(params[:id])

      respond_to do |format|
        if @vm_os_type.update_attributes(params[:vm_os_type])
          flash[:notice] = 'VmOsType was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
          format.js
        else
          @error_messages = @vm_os_type.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "edit" }
          format.xml  { render :xml => @vm_os_type.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # DELETE /vm_os_types/1
  # DELETE /vm_os_types/1.xml
  def destroy
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :vm_os_types,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    @vm_os_type = VmOsType.find(params[:id])
    @vm_os_type.destroy

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
      format.js
    end
  end

  def sort
    params[:provider_vm_os_types].each_with_index do |id, index|
      VmOsType.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
