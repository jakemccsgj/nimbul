class Parent::ServerProfileRevisionsController < ApplicationController
    parent_resources :server_image
    before_filter :login_required
    require_role  :admin, :unless => "current_user.has_access?(parent)"

    def index
        # commented out refresh from ui for performance reasons
        parent.refresh(params[:refresh]) if params[:refresh] and parent.respond_to?('refresh')
        
        joins = nil
        conditions = nil
        @server_profile_revisions  = ServerProfileRevision.search_by_parent(parent, params[:search], params[:page], joins, conditions, params[:sort], params[:filter], [ { :servers => :cluster }, :server_profile ])

        @parent_type = parent_type
        @parent = parent
        @controls_enabled = true
        respond_to do |format|
            format.html
            format.xml  { render :xml => @server_profile_revisions }
            format.js
        end
    end
    def list
        index
    end

    # DELETE /server_profile_revisions/1
    # DELETE /server_profile_revisions/1.xml
    def destroy
        @parent = parent
        @server_profile_revision = @parent.server_profile_revisions.find(params[:id])
        if @server_profile_revision.destroy
                o = @server_profile_revision
                provider_account_id = nil
                provider_account_name = nil
                if parent.respond_to?('provider_account_id')
                    provider_account_id = parent.provider_account_id
                    provider_account_name = parent.provider_account.name
                end
                AuditLog.create(
                    :provider_account_name => provider_account_name,
                    :provider_account_id => provider_account_id,
                    :cluster_name => nil,
                    :cluster_id => nil,
                    :auditable_id => o.id,
                    :auditable_type => o.class.to_s,
                    :auditable_name => nil,
                    :author_login => current_user.login,
                    :author_id => current_user.id,
                    :summary => "deleted server profile revision",
                    :changes => o.tracked_changes,
                    :force => true
                )
        end

        respond_to do |format|
            format.html { redirect_to(server_profile_revisions_url) }
            format.xml  { head :ok }
            format.js
        end
    end
end
