class LoadBalancersController < ApplicationController
  parent_resources :provider_account
  before_filter :login_required
  require_role  :admin, :unless => "current_user.has_access?(parent)"

  # GET /load_balancers
  # GET /load_balancers.xml
  def index
    @load_balancers = parent.load_balancers

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @load_balancers }
      format.js
    end
  end

  # GET /load_balancers/new
  # GET /load_balancers/new.xml
  def new
    @load_balancer = parent.load_balancers.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @load_balancer }
      format.js
    end
  end

  # GET /load_balancers/1/edit
  def edit
    @load_balancer = parent.load_balancers.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @load_balancer }
      format.js
    end
  end

  # POST /load_balancers
  # POST /load_balancers.xml
  def create
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :load_balancers,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @load_balancer = parent.load_balancers.build(params[:load_balancer])

      respond_to do |format|
        if @load_balancer.save
          flash[:notice] = 'LoadBalancer was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @load_balancer, :status => :created, :location => @load_balancer }
          format.js
        else
          @error_messages = @load_balancer.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "new" }
          format.xml  { render :xml => @load_balancer.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /load_balancers/1
  # PUT /load_balancers/1.xml
  def update
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :load_balancers,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @load_balancer = LoadBalancer.find(params[:id])

      respond_to do |format|
        if @load_balancer.update_attributes(params[:load_balancer])
          flash[:notice] = 'LoadBalancer was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
          format.js
        else
          @error_messages = @load_balancer.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "edit" }
          format.xml  { render :xml => @load_balancer.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # DELETE /load_balancers/1
  # DELETE /load_balancers/1.xml
  def destroy
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :load_balancers,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    @load_balancer = LoadBalancer.find(params[:id])
    @load_balancer.destroy

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
      format.js
    end
  end

  def sort
    params[:provider_load_balancers].each_with_index do |id, index|
      LoadBalancer.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
