class Admin::UsersController < ApplicationController
  before_filter :login_required
  require_role :admin

  def index
    search = params[:search]
    options = {
      :page => params[:page],
      :order => params[:sort],
      :filters => params[:filter],
      :include => [ :roles, :provider_accounts, :clusters ],
    }
    @users = User.search(search, options)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
      format.js
    end
  end
  def list
    index
  end

  # Administrative activate action
  def update
    @user = User.find(params[:id], :include => [ :roles, :provider_accounts, :clusters ])
    if @user.activate!
      flash[:notice] = "User activated."
    else
      flash[:error] = "There was a problem activating this user."
    end
                
    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml  { render :xml => @user }
      format.js   { render :partial => 'users/user.js.rjs', :object => @user, :layout => false }
    end
  end
end
