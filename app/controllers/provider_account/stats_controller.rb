class ProviderAccount::StatsController < ApplicationController
  before_filter :login_required
  require_role  :admin,
    :unless => "current_user.has_provider_account_access?(ProviderAccount.find(params[:provider_account_id])) "

  def index
    @provider_account = ProviderAccount.find(params[:provider_account_id], :include => [ :clusters, :reserved_instances, :zones, :account_group ])
    @zones = @provider_account.zones
    @account_group = @provider_account.account_group

    reserved_select = []
    reserved_select << 'select zone_id, instance_type, sum(count) as count, usage_price from reserved_instances'
    reserved_select << ''
    reserved_select << 'group by zone_id, instance_type, usage_price'
    reserved_select << 'order by usage_price'

    running_select = []
    running_select << 'select z.id as zone_id, instance_type, count(i.id) as count from instances i, zones z where i.zone_id = z.id and'
    running_select << ''
    running_select << 'group by zone_id, instance_type'
    running_select << 'order by z.name'
    condition = {}

    if @account_group.nil?
      reserved_select[1] = 'where provider_account_id=:provider_account_id'
      running_select[1] = 'i.provider_account_id=:provider_account_id'
      condition = { :provider_account_id => @provider_account.id }
    else
      reserved_select[1] = 'where provider_account_id in (select id from provider_accounts where account_group_id=:account_group_id)'
      running_select[1] = 'i.provider_account_id in (select id from provider_accounts where account_group_id=:account_group_id)'
      condition = { :account_group_id => @account_group.id }
    end

    @reserved_instances = ReservedInstance.find_by_sql([reserved_select.join(' '), condition])
    @running_instances = ReservedInstance.find_by_sql([running_select.join(' '), condition])

    latest_taken_at = ServerStat.maximum(:taken_at, :conditions => { :cluster_id => @provider_account.cluster_ids })
    @server_stats = ServerStat.find_all_by_cluster_id_and_taken_at(@provider_account.cluster_ids, latest_taken_at, :include => [:cluster, :server])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @latest_stat_record }
      format.js   { render :partial => 'stats/list', :layout => false }
    end
	end

end
