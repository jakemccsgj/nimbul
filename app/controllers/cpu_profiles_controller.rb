class CpuProfilesController < ApplicationController
  before_filter :login_required
  require_role  :admin

  # GET /cpu_profiles
  # GET /cpu_profiles.xml
  def index
    @cpu_profiles = CpuProfile.find(:all, :order => 'position')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cpu_profiles }
    end
  end

  # GET /cpu_profiles/1
  # GET /cpu_profiles/1.xml
  def show
    @cpu_profile = CpuProfile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cpu_profile }
    end
  end

  # GET /cpu_profiles/new
  # GET /cpu_profiles/new.xml
  def new
    @cpu_profile = CpuProfile.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cpu_profile }
    end
  end

  # GET /cpu_profiles/1/edit
  def edit
    @cpu_profile = CpuProfile.find(params[:id])
  end

  # POST /cpu_profiles
  # POST /cpu_profiles.xml
  def create
    redirect_url = cpu_profiles_url

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @cpu_profile = CpuProfile.new(params[:cpu_profile])

      respond_to do |format|
        if @cpu_profile.save
          flash[:notice] = 'CpuProfile was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @cpu_profile, :status => :created, :location => @cpu_profile }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @cpu_profile.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /cpu_profiles/1
  # PUT /cpu_profiles/1.xml
  def update
    redirect_url = cpu_profiles_url

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @cpu_profile = CpuProfile.find(params[:id])

      respond_to do |format|
        if @cpu_profile.update_attributes(params[:cpu_profile])
          flash[:notice] = 'CpuProfile was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @cpu_profile.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /cpu_profiles/1
  # DELETE /cpu_profiles/1.xml
  def destroy
    @cpu_profile = CpuProfile.find(params[:id])
    @cpu_profile.destroy

    respond_to do |format|
      format.html { redirect_to(cpu_profiles_url) }
      format.xml  { head :ok }
    end
  end

  def sort
    params[:cpu_profiles].each_with_index do |id, index|
      CpuProfile.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
