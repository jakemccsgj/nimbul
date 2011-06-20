class AccountGroupsController < ApplicationController
  before_filter :login_required
  require_role :admin

  # GET /account_groups
  # GET /account_groups.xml
  def index
    @account_groups = AccountGroup.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @account_groups }
    end
  end

  # GET /account_groups/1
  # GET /account_groups/1.xml
  def show
    @account_group = AccountGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account_group }
    end
  end

  # GET /account_groups/new
  # GET /account_groups/new.xml
  def new
    @account_group = AccountGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account_group }
    end
  end

  # GET /account_groups/1/edit
  def edit
    @account_group = AccountGroup.find(params[:id], :include => :provider_accounts)
  end

  # POST /account_groups
  # POST /account_groups.xml
  def create
    redirect_url = account_groups_url

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @account_group = AccountGroup.new(params[:account_group])
      @account_group.provider_account_ids = params[:account_group][:provider_account_ids]

      respond_to do |format|
        if @account_group.save
          flash[:notice] = 'AccountGroup was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @account_group, :status => :created, :location => @account_group }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @account_group.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /account_groups/1
  # PUT /account_groups/1.xml
  def update
    redirect_url = account_groups_url

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @account_group = AccountGroup.find(params[:id])
      @account_group.provider_account_ids = params[:account_group][:provider_account_ids]

      respond_to do |format|
        if @account_group.update_attributes(params[:account_group])
          flash[:notice] = 'AccountGroup was successfully updated.'
          format.html { redirect_to account_groups_path }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @account_group.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /account_groups/1
  # DELETE /account_groups/1.xml
  def destroy
    @account_group = AccountGroup.find(params[:id])
    @account_group.destroy

    respond_to do |format|
      format.html { redirect_to(account_groups_url) }
      format.xml  { head :ok }
    end
  end
end
