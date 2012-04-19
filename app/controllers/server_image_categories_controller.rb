class ServerImageCategoriesController < ApplicationController
  parent_resources :provider_account
  before_filter :login_required
  require_role  :admin, :unless => "current_user.has_access?(parent)"

  # GET /server_image_categories
  # GET /server_image_categories.xml
  def index
    @server_image_categories = parent.server_image_categories

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @server_image_categories }
      format.js
    end
  end

  # GET /server_image_categories/new
  # GET /server_image_categories/new.xml
  def new
    @server_image_category = parent.server_image_categories.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @server_image_category }
      format.js
    end
  end

  # GET /server_image_categories/1/edit
  def edit
    @server_image_category = parent.server_image_categories.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @server_image_category }
      format.js
    end
  end

  # POST /server_image_categories
  # POST /server_image_categories.xml
  def create
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :images,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @server_image_category = parent.server_image_categories.build(params[:server_image_category])

      respond_to do |format|
        if @server_image_category.save
          flash[:notice] = 'ServerImageCategory was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @server_image_category, :status => :created, :location => @server_image_category }
          format.js
        else
          @error_messages = @server_image_category.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "new" }
          format.xml  { render :xml => @server_image_category.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # PUT /server_image_categories/1
  # PUT /server_image_categories/1.xml
  def update
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :images,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @server_image_category = ServerImageCategory.find(params[:id])

      respond_to do |format|
        if @server_image_category.update_attributes(params[:server_image_category])
          flash[:notice] = 'ServerImageCategory was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
          format.js
        else
          @error_messages = @server_image_category.errors.collect{ |e| e[0].humanize+' - '+e[1] }
          format.html { render :action => "edit" }
          format.xml  { render :xml => @server_image_category.errors, :status => :unprocessable_entity }
          format.js
        end
      end
    end
  end

  # DELETE /server_image_categories/1
  # DELETE /server_image_categories/1.xml
  def destroy
    options = {
      :search => params[:search],
      :sort => params[:sort],
      :page => params[:page],
      :anchor => :images,
    }
    redirect_url = send("#{ parent_type }_url", parent, options)

    @server_image_category = ServerImageCategory.find(params[:id])
    @server_image_category.destroy

    respond_to do |format|
      format.html { redirect_to redirect_url }
      format.xml  { head :ok }
      format.js
    end
  end

  def sort
    params[:provider_account_server_image_categories].each_with_index do |id, index|
      ServerImageCategory.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
