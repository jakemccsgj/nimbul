class VmPricesController < ApplicationController
  parent_resources :provider
  before_filter :login_required
  require_role  :admin

  # GET /vm_prices
  # GET /vm_prices.xml
  def index
    @vm_prices = parent.vm_prices

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @vm_prices }
      format.js
    end
  end

  # GET /vm_prices/new
  # GET /vm_prices/new.xml
  def new
    @vm_price = parent.vm_prices.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @vm_price }
      format.js
    end
  end

  # GET /vm_prices/1/edit
  def edit
    @vm_price = parent.vm_prices.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @vm_price }
      format.js
    end
  end

  # POST /vm_prices
  # POST /vm_prices.xml
  def create
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :vm_prices,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @vm_price = parent.vm_prices.build(params[:vm_price])

      respond_to do |format|
        if @vm_price.save
          flash[:notice] = 'VmPrice was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @vm_price, :status => :created, :location => @vm_price }
          format.js
        else
          @error_messages = @vm_price.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "new" }
          format.xml  { render :xml => @vm_price.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /vm_prices/1
  # PUT /vm_prices/1.xml
  def update
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :vm_prices,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @vm_price = VmPrice.find(params[:id])

      respond_to do |format|
        if @vm_price.update_attributes(params[:vm_price])
          flash[:notice] = 'VmPrice was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
          format.js
        else
          @error_messages = @vm_price.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "edit" }
          format.xml  { render :xml => @vm_price.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # DELETE /vm_prices/1
  # DELETE /vm_prices/1.xml
  def destroy
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :vm_prices,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    @vm_price = VmPrice.find(params[:id])
    @vm_price.destroy

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
      format.js
    end
  end

  def sort
    params[:provider_vm_prices].each_with_index do |id, index|
      VmPrice.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
