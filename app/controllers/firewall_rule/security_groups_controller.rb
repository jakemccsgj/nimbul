class FirewallRule::SecurityGroupsController < ApplicationController
	before_filter :login_required
	require_role  :admin,
    :unless => "current_user.has_firewall_rule_access?(FirewallRule.find(params[:firewall_rule_id]))"

	def index
		@firewall_rule = FirewallRule.find(params[:firewall_rule_id])
		@provider_account = @firewall_rule.provider_account

    search = params[:search]
		options ={
      :page => params[:page],
      :order => params[:sort],
      :filters => params[:filter]
    }
    @security_groups = SecurityGroup.search_by_firewall_rule(@firewall_rule, search, options)

		@partial ||= 'security_groups/index'
    respond_to do |format|
      format.html
      format.xml  { render :xml => @security_groups }
      format.js   { render :partial => @partial, :layout => false }
    end
	end
	def list
		@partial = 'security_groups/list'
		index
	end
end
