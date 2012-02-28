class OsTypesController < ApplicationController
  before_filter :login_required
  require_role  :admin

  # GET /os_types
  # GET /os_types.xml
  def index
    @os_types = OsType.find(:all, :order => 'position')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @os_types }
    end
  end

  # GET /os_types/1
  # GET /os_types/1.xml
  def show
    @os_type = OsType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @os_type }
    end
  end

  # GET /os_types/new
  # GET /os_types/new.xml
  def new
    @os_type = OsType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @os_type }
    end
  end

  # GET /os_types/1/edit
  def edit
    @os_type = OsType.find(params[:id])
  end

  # POST /os_types
  # POST /os_types.xml
  def create
    redirect_url = os_types_url

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @os_type = OsType.new(params[:os_type])

      respond_to do |format|
        if @os_type.save
          flash[:notice] = 'OsType was successfully created.'
          format.html { redirect_to redirect_url }
          format.xml  { render :xml => @os_type, :status => :created, :location => @os_type }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @os_type.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /os_types/1
  # PUT /os_types/1.xml
  def update
    redirect_url = os_types_url

    if params[:cancel_button]
      redirect_to redirect_url
    else
      @os_type = OsType.find(params[:id])

      respond_to do |format|
        if @os_type.update_attributes(params[:os_type])
          flash[:notice] = 'OsType was successfully updated.'
          format.html { redirect_to redirect_url }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @os_type.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /os_types/1
  # DELETE /os_types/1.xml
  def destroy
    @os_type = OsType.find(params[:id])
    @os_type.destroy

    respond_to do |format|
      format.html { redirect_to(os_types_url) }
      format.xml  { head :ok }
    end
  end

  def sort
    params[:os_types].each_with_index do |id, index|
      OsType.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
