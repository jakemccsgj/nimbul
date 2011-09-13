class HealthChecksController < ApplicationController
  # GET /health_checks
  # GET /health_checks.xml
  def index
    @health_checks = HealthCheck.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @health_checks }
    end
  end

  # GET /health_checks/1
  # GET /health_checks/1.xml
  def show
    @health_check = HealthCheck.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @health_check }
    end
  end

  # GET /health_checks/new
  # GET /health_checks/new.xml
  def new
    @health_check = HealthCheck.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @health_check }
    end
  end

  # GET /health_checks/1/edit
  def edit
    @health_check = HealthCheck.find(params[:id])
  end

  # POST /health_checks
  # POST /health_checks.xml
  def create
    @health_check = HealthCheck.new(params[:health_check])

    respond_to do |format|
      if @health_check.save
        flash[:notice] = 'HealthCheck was successfully created.'
        format.html { redirect_to(@health_check) }
        format.xml  { render :xml => @health_check, :status => :created, :location => @health_check }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @health_check.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /health_checks/1
  # PUT /health_checks/1.xml
  def update
    @health_check = HealthCheck.find(params[:id])

    respond_to do |format|
      if @health_check.update_attributes(params[:health_check])
        flash[:notice] = 'HealthCheck was successfully updated.'
        format.html { redirect_to(@health_check) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @health_check.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /health_checks/1
  # DELETE /health_checks/1.xml
  def destroy
    @health_check = HealthCheck.find(params[:id])
    @health_check.destroy

    respond_to do |format|
      format.html { redirect_to(health_checks_url) }
      format.xml  { head :ok }
    end
  end
end
