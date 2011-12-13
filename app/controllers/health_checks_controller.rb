class HealthChecksController < ApplicationController
  parent_resources :load_balancer
  before_filter :login_required
  require_role  :admin, :unless => "current_user.has_access?(parent)"

  # GET /health_checks
  # GET /health_checks.xml
  def index
    @health_checks = parent.health_checks

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @health_checks }
      format.js
    end
  end

  # GET /health_checks/new
  # GET /health_checks/new.xml
  def new
    @health_check = parent.health_checks.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @health_check }
      format.js
    end
  end

  # GET /health_checks/1/edit
  def edit
    @health_check = parent.health_checks.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @health_check }
      format.js
    end
  end

  # POST /health_checks
  # POST /health_checks.xml
  def create
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :health_checks,
    }
    redirect_url = send("#{ parent_type }_health_checks_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @health_check = parent.health_checks.build(params[:health_check])

      respond_to do |format|
        if @health_check.save
          flash[:notice] = 'HealthCheck was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @health_check, :status => :created, :location => @health_check }
          format.js
        else
          @error_messages = @health_check.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "new" }
          format.xml  { render :xml => @health_check.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /health_checks/1
  # PUT /health_checks/1.xml
  def update
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :health_checks,
    }
    redirect_url = send("#{ parent_type }_health_checks_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @health_check = HealthCheck.find(params[:id])

      respond_to do |format|
        if @health_check.update_attributes(params[:health_check])
          flash[:notice] = 'HealthCheck was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
          format.js
        else
          @error_messages = @health_check.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "edit" }
          format.xml  { render :xml => @health_check.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # DELETE /health_checks/1
  # DELETE /health_checks/1.xml
  def destroy
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :health_checks,
    }
    redirect_url = send("#{ parent_type }_health_checks_url", parent, options)

    @health_check = HealthCheck.find(params[:id])
    @health_check.destroy

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
      format.js
    end
  end

  def update_target_path
    render :update do |page|
      if ELB_TARGET_PROTOCOL_WITH_PATH_NAMES.include?(params[:target_protocol])
        page["health_check_#{params[:id]}_target_path"].show 
      else
        page["health_check_#{params[:id]}_target_path"].hide 
      end
    end
  end

  def sort
    params[:provider_health_checks].each_with_index do |id, index|
      HealthCheck.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
