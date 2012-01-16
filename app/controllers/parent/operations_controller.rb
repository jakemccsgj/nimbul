class Parent::OperationsController < ApplicationController
  parent_resources :server, :task
  before_filter :login_required
  require_role  :admin, :unless => "current_user.has_access?(parent)"

  def index
    parent.refresh(params[:refresh]) if params[:refresh] and parent.respond_to?('refresh')
    params[:sort] = 'created_at_reverse' if params[:sort].blank?

    search = params[:search]
    options = {
      :page => params[:page],
      :order => params[:sort],
      :filter => params[:filter],
    }
    @operations = Operation.search_by_parent(parent, search, options)
    @parent_type = parent_type
    @parent = parent

    respond_to do |format|
      format.html
      format.xml  { render :xml => @operations }
      format.js 
    end
  end

  def list
    index
  end

	def show
    @parent = parent
    @parent_type = parent_type
    
    @operation = Operation.find(params[:id], :include => :operation_logs)
    @operation_logs = @operation.operation_logs

    respond_to do |format|
      format.html
      format.xml { render :xml => @operation_logs }
      format.js
    end
	end
end
