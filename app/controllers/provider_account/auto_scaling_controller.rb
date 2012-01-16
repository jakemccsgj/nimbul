class ProviderAccount::AutoScalingController < ApplicationController
	before_filter :login_required
	require_role  :admin,
		:unless => "current_user.has_provider_account_access?(ProviderAccount.find(params[:provider_account_id]))"

	# GET /provider_accounts/1/auto_scaling
	# GET /provider_accounts/1/auto_scaling.xml
	# GET /provider_accounts/1/auto_scaling.js
	def index
		@provider_account = ProviderAccount.find(params[:provider_account_id])
		
		if params[:refresh]
      refresh = params[:refresh].gsub(/_data/, 's')
      @provider_account.refresh(refresh)
    end

    if params[:launch_configuration_search]
  		search = params[:launch_configuration_search]
      options ={
        :page => params[:launch_configuration_page],
        :order => params[:sort],
        :include => [ :server, :server_image, :provider_account, :auto_scaling_groups, :server_profile_revision, :instance_vm_type ],
      }
      @launch_configurations = LaunchConfiguration.search_by_provider_account(@provider_account, search, options)
    end

    if params[:auto_scaling_group_search]
      search = params[:auto_scaling_group_search]
      options ={
        :page => params[:auto_scaling_group_page],
        :order => params[:sort],
        :include => [ :launch_configuration, :provider_account, :zones, :instances ],
      }
      @auto_scaling_groups   = AutoScalingGroup.search_by_provider_account(@provider_account, search, options)
    end
		
		if params[:sort] =~ /launch_configuration/
			@auto_scaling_groups.sort! { |a,b| a.launch_configuration.name <=> b.launch_configuration.name }
			@auto_scaling_groups.reverse! if params[:sort] =~ /_reverse/
		end
		
		respond_to do |format|
			format.html { render :template => 'auto_scaling/index' }
			format.xml  {
				render :xml => {
					:launch_configurations => @launch_configurations,
					:auto_scaling_groups => @auto_scaling_groups
				}
			}
			format.js   {
				render :template => (@refresh ? 'auto_scaling/refresh' : 'auto_scaling/index'), :layout => false
			}
		end
	end

	def list
		index
	end
end

