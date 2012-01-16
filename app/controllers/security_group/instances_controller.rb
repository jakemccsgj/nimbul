class SecurityGroup::InstancesController < ApplicationController
  before_filter :login_required
  require_role  :admin,
    :unless => "current_user.has_security_group_access?(SecurityGroup.find(params[:security_group_id])) "

  def index
		@security_group = SecurityGroup.find(params[:security_group_id])

    search = params[:search]
    options ={
      :page => params[:page],
      :filters => params[:filter]
    }
    @instances  = Instance.search_by_security_group(@security_group, search, options)

    @skip_server_column = true
    respond_to do |format|
      format.html
      format.xml  { render :xml => @instances }
      format.js
    end
  end
  def list
    index
  end
end

