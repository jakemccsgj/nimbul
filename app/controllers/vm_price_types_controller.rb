class VmPriceTypesController < ApplicationController
  parent_resources :provider
  before_filter :login_required
  require_role  :admin

  # GET /vm_price_types
  # GET /vm_price_types.xml
  def index
    @vm_price_types = parent.vm_price_types

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @vm_price_types }
      format.js
    end
  end

  # GET /vm_price_types/new
  # GET /vm_price_types/new.xml
  def new
    @vm_price_type = parent.vm_price_types.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @vm_price_type }
      format.js
    end
  end

  # GET /vm_price_types/1/edit
  def edit
    @vm_price_type = parent.vm_price_types.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @vm_price_type }
      format.js
    end
  end

  # POST /vm_price_types
  # POST /vm_price_types.xml
  def create
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :vm_price_types,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @vm_price_type = parent.vm_price_types.build(params[:vm_price_type])

      respond_to do |format|
        if @vm_price_type.save
          flash[:notice] = 'VmPriceType was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @vm_price_type, :status => :created, :location => @vm_price_type }
          format.js
        else
          @error_messages = @vm_price_type.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "new" }
          format.xml  { render :xml => @vm_price_type.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /vm_price_types/1
  # PUT /vm_price_types/1.xml
  def update
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :vm_price_types,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @vm_price_type = VmPriceType.find(params[:id])

      respond_to do |format|
        if @vm_price_type.update_attributes(params[:vm_price_type])
          flash[:notice] = 'VmPriceType was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
          format.js
        else
          @error_messages = @vm_price_type.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "edit" }
          format.xml  { render :xml => @vm_price_type.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # DELETE /vm_price_types/1
  # DELETE /vm_price_types/1.xml
  def destroy
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :vm_price_types,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    @vm_price_type = VmPriceType.find(params[:id])
    @vm_price_type.destroy

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
      format.js
    end
  end

  def sort
    params[:provider_vm_price_types].each_with_index do |id, index|
      VmPriceType.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
