class IoProfilesController < ApplicationController
  before_filter :login_required
  require_role  :admin

  # GET /io_profiles
  # GET /io_profiles.xml
  def index
    @io_profiles = IoProfile.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @io_profiles }
    end
  end

  # GET /io_profiles/1
  # GET /io_profiles/1.xml
  def show
    @io_profile = IoProfile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @io_profile }
    end
  end

  # GET /io_profiles/new
  # GET /io_profiles/new.xml
  def new
    @io_profile = IoProfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @io_profile }
    end
  end

  # GET /io_profiles/1/edit
  def edit
    @io_profile = IoProfile.find(params[:id])
  end

  # POST /io_profiles
  # POST /io_profiles.xml
  def create
    redirect_url = io_profiles_url

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @io_profile = IoProfile.new(params[:io_profile])

      respond_to do |format|
        if @io_profile.save
          flash[:notice] = 'IoProfile was successfully created.'
          format.html { redirect_to(@io_profile) }
          format.xml  { render :xml => @io_profile, :status => :created, :location => @io_profile }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @io_profile.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /io_profiles/1
  # PUT /io_profiles/1.xml
  def update
    redirect_url = io_profiles_url

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @io_profile = IoProfile.find(params[:id])

      respond_to do |format|
        if @io_profile.update_attributes(params[:io_profile])
          flash[:notice] = 'IoProfile was successfully updated.'
          format.html { redirect_to(@io_profile) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @io_profile.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /io_profiles/1
  # DELETE /io_profiles/1.xml
  def destroy
    @io_profile = IoProfile.find(params[:id])
    @io_profile.destroy

    respond_to do |format|
      format.html { redirect_to(io_profiles_url) }
      format.xml  { head :ok }
    end
  end

  def sort
    params[:io_profile].each_with_index do |id, index|
      IoProfile.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
