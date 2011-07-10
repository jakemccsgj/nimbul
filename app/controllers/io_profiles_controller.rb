class IoProfilesController < ApplicationController
  # GET /io_profiles
  # GET /io_profiles.xml
  def index
    @io_profiles = IoProfiles.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @io_profiles }
    end
  end

  # GET /io_profiles/1
  # GET /io_profiles/1.xml
  def show
    @io_profiles = IoProfiles.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @io_profiles }
    end
  end

  # GET /io_profiles/new
  # GET /io_profiles/new.xml
  def new
    @io_profiles = IoProfiles.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @io_profiles }
    end
  end

  # GET /io_profiles/1/edit
  def edit
    @io_profiles = IoProfiles.find(params[:id])
  end

  # POST /io_profiles
  # POST /io_profiles.xml
  def create
    @io_profiles = IoProfiles.new(params[:io_profiles])

    respond_to do |format|
      if @io_profiles.save
        flash[:notice] = 'IoProfiles was successfully created.'
        format.html { redirect_to(@io_profiles) }
        format.xml  { render :xml => @io_profiles, :status => :created, :location => @io_profiles }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @io_profiles.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /io_profiles/1
  # PUT /io_profiles/1.xml
  def update
    @io_profiles = IoProfiles.find(params[:id])

    respond_to do |format|
      if @io_profiles.update_attributes(params[:io_profiles])
        flash[:notice] = 'IoProfiles was successfully updated.'
        format.html { redirect_to(@io_profiles) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @io_profiles.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /io_profiles/1
  # DELETE /io_profiles/1.xml
  def destroy
    @io_profiles = IoProfiles.find(params[:id])
    @io_profiles.destroy

    respond_to do |format|
      format.html { redirect_to(io_profiles_url) }
      format.xml  { head :ok }
    end
  end
end
