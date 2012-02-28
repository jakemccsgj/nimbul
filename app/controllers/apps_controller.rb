class AppsController < ApplicationController
  parent_resources :account_group
  before_filter :login_required
  require_role  :admin

  # GET /apps
  # GET /apps.xml
  def index
    @apps = parent.apps

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @apps }
      format.js
    end
  end

  # GET /apps/new
  # GET /apps/new.xml
  def new
    @app = parent.apps.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @app }
      format.js
    end
  end

  # GET /apps/1/edit
  def edit
    @app = parent.apps.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @app }
      format.js
    end
  end

  # POST /apps
  # POST /apps.xml
  def create
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :apps,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @app = parent.apps.build(params[:app])

      respond_to do |format|
        if @app.save
          flash[:notice] = 'App was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @app, :status => :created, :location => @app }
          format.js
        else
          @error_messages = @app.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "new" }
          format.xml  { render :xml => @app.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /apps/1
  # PUT /apps/1.xml
  def update
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :apps,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @app = App.find(params[:id])

      respond_to do |format|
        if @app.update_attributes(params[:app])
          flash[:notice] = 'App was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
          format.js
        else
          @error_messages = @app.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "edit" }
          format.xml  { render :xml => @app.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # DELETE /apps/1
  # DELETE /apps/1.xml
  def destroy
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :apps,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    @app = App.find(params[:id])
    @app.destroy

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
      format.js
    end
  end

  def sort
    params[:account_group_apps].each_with_index do |id, index|
      App.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
