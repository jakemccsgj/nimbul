class LoadBalancerPoliciesController < ApplicationController
  # GET /load_balancer_policies
  # GET /load_balancer_policies.xml
  def index
    @load_balancer_policies = LoadBalancerPolicy.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @load_balancer_policies }
    end
  end

  # GET /load_balancer_policies/1
  # GET /load_balancer_policies/1.xml
  def show
    @load_balancer_policy = LoadBalancerPolicy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @load_balancer_policy }
    end
  end

  # GET /load_balancer_policies/new
  # GET /load_balancer_policies/new.xml
  def new
    @load_balancer_policy = LoadBalancerPolicy.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @load_balancer_policy }
    end
  end

  # GET /load_balancer_policies/1/edit
  def edit
    @load_balancer_policy = LoadBalancerPolicy.find(params[:id])
  end

  # POST /load_balancer_policies
  # POST /load_balancer_policies.xml
  def create
    @load_balancer_policy = LoadBalancerPolicy.new(params[:load_balancer_policy])

    respond_to do |format|
      if @load_balancer_policy.save
        flash[:notice] = 'LoadBalancerPolicy was successfully created.'
        format.html { redirect_to(@load_balancer_policy) }
        format.xml  { render :xml => @load_balancer_policy, :status => :created, :location => @load_balancer_policy }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @load_balancer_policy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /load_balancer_policies/1
  # PUT /load_balancer_policies/1.xml
  def update
    @load_balancer_policy = LoadBalancerPolicy.find(params[:id])

    respond_to do |format|
      if @load_balancer_policy.update_attributes(params[:load_balancer_policy])
        flash[:notice] = 'LoadBalancerPolicy was successfully updated.'
        format.html { redirect_to(@load_balancer_policy) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @load_balancer_policy.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /load_balancer_policies/1
  # DELETE /load_balancer_policies/1.xml
  def destroy
    @load_balancer_policy = LoadBalancerPolicy.find(params[:id])
    @load_balancer_policy.destroy

    respond_to do |format|
      format.html { redirect_to(load_balancer_policies_url) }
      format.xml  { head :ok }
    end
  end
end
