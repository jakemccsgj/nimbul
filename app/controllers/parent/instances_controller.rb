class Parent::InstancesController < ApplicationController
    parent_resources :provider_account, :cluster, :server, :auto_scaling_group, :load_balancer, :owner
    before_filter :login_required
    require_role  :admin, :unless => "current_user.has_access?(parent)"

    def index
        # commented out refresh from ui for performance reasons
        parent.refresh(params[:refresh]) if params[:refresh] and parent.respond_to?('refresh')
        
        joins = nil
        conditions = nil
        @instances  = Instance.search_by_parent(parent, params[:search], params[:page], joins, conditions, params[:sort], params[:filter], [ :zone, :server, :user, :security_groups, :provider_account, :instance_vm_type ])

        @parent_type = parent_type
        @parent = parent
        @controls_enabled = true
        respond_to do |format|
            format.html
            format.xml  { render :xml => @instances }
            format.js
        end
    end
    def list
        index
    end
    
    def self.control_instances(instances, command)
        success = true
        messages = []
        error_messages = []
        instances.each do |instance|
            begin
                if command == 'stop'
                    instance.stop!
                end
                if command == 'start'
                    instance.start!
                end
                if command == 'reboot'
                    instance.reboot!
                end
                if command == 'terminate'
                    instance.terminate!
                end
                if instance.errors.empty?
                    messages << "#{instance.instance_id} - #{command} successful"
                else
                    error_messages << instance.errors.collect{ |e| "#{instance.instance_id} - #{e[0].humanize}, #{e[1]}" }
                    success = false
                end
            rescue  Exception => e
                error_messages << "#{instance.instance_id} - failed to #{command}: #{e.message}"
                success = false
            end
        end
        messages << error_messages
        yield success, instances, messages
    end
    
    def control
        joins = nil
        conditions = nil
        instances  = Instance.find(params[:instance_ids], :include => [ :zone, :server, :user, :security_groups, :provider_account ])
        @instances = instances.select{ |i| current_user.has_access?(i) }
        @messages = []
        @error_messages = []
        
        options = {
            :search => params[:search],
            :sort => params[:sort],
            :page => params[:page],
            :anchor => :instances,
        }
        redirect_url = send("#{ parent_type }_url", parent, options)

        @error_message = ''
        if @instances.size == 0
            @error_message = "No instances are specified."
        else
            self.class.control_instances(@instances, params[:instance_command]) do |success, instances, messages|
                @instances = instances
                @success = success
                if success
                    @messages = messages
                    @instances.each do |i|
                        p = i.server.nil? ? parent : i.server
                        o = i
                        AuditLog.create_for_parent(
                            :parent => p,
                            :auditable_id => o.id,
                            :auditable_type => o.class.to_s,
                            :auditable_name => o.name,
                            :author_login => current_user.login,
                            :author_id => current_user.id,
                            :summary => "#{params[:instance_command]} '#{o.name}'",
                            :changes => o.tracked_changes,
                            :force => true
                        )
                    end
                else
                    @error_messages = messages
                end
            end
        end

        @controls_enabled = true
        respond_to do |format|
            if @error_message.blank?
                flash[:notice] = @messages.join('<br/>')
                format.html { redirect_to redirect_url }
                format.xml  { head :ok }
                format.js
            else
                flash[:error] = @error_messages.join('<br/>')
                format.html { redirect_to redirect_url }
                format.xml  { render :xml => @error_message, :status => :unprocessable_entity }
                format.js
            end
        end
    end
end
