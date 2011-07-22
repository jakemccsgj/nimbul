class RegionsController < ApplicationController
  parent_resources :provider
  before_filter :login_required
  require_role  :admin

  # GET /regions
  # GET /regions.xml
  def index
    @regions = parent.regions

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @regions }
      format.js
    end
  end

  # GET /regions/new
  # GET /regions/new.xml
  def new
    @region = parent.regions.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @region }
      format.js
    end
  end

  # GET /regions/1/edit
  def edit
    @region = parent.regions.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @region }
      format.js
    end
  end

  # POST /regions
  # POST /regions.xml
  def create
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :regions,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @region = parent.regions.build(params[:region])

      respond_to do |format|
        if @region.save
          flash[:notice] = 'Region was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @region, :status => :created, :location => @region }
          format.js
        else
          @error_messages = @region.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "new" }
          format.xml  { render :xml => @region.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /regions/1
  # PUT /regions/1.xml
  def update
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :regions,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @region = Region.find(params[:id])

      respond_to do |format|
        if @region.update_attributes(params[:region])
          flash[:notice] = 'Region was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
          format.js
        else
          @error_messages = @region.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "edit" }
          format.xml  { render :xml => @region.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # DELETE /regions/1
  # DELETE /regions/1.xml
  def destroy
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :regions,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    @region = Region.find(params[:id])
    @region.destroy

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
      format.js
    end
  end

  def sort
    params[:provider_regions].each_with_index do |id, index|
      Region.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
