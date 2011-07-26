class ProviderAccount::StatsController < ApplicationController
  before_filter :login_required
  require_role  :admin,
    :unless => "current_user.has_provider_account_access?(ProviderAccount.find(params[:provider_account_id])) "

  def index
    @provider_account = ProviderAccount.find(params[:provider_account_id], :include => [ :clusters, :reserved_instances, :account_group ])
    @zones = @provider_account.zones
    @account_group = @provider_account.account_group

    reserved_select = []
    reserved_select << 'select z.id as zone_id, instance_vm_type_id, sum(count) as count, usage_price from reserved_instances i, zones z where i.zone_id = z.id and'
    reserved_select << ''
    reserved_select << 'group by zone_id, instance_vm_type_id, usage_price'
    reserved_select << 'order by z.name, usage_price'

    running_select = []
    running_select << 'select z.id as zone_id, instance_vm_type_id, count(i.id) as count from instances i, zones z where i.zone_id = z.id and'
    running_select << ''
    running_select << 'group by zone_id, instance_vm_type_id'
    running_select << 'order by z.name'
    condition = {}

    if @account_group.nil?
      reserved_select[1] = 'i.provider_account_id=:provider_account_id'
      running_select[1] = reserved_select[1]
      condition = { :provider_account_id => @provider_account.id }
    else
      reserved_select[1] = 'i.provider_account_id in (select id from provider_accounts where account_group_id=:account_group_id)'
      running_select[1] = reserved_select[1]
      condition = { :account_group_id => @account_group.id }
    end

    @reserved_instances = ReservedInstance.find_by_sql([reserved_select.join(' '), condition])
    @running_instances = ReservedInstance.find_by_sql([running_select.join(' '), condition])

    latest_taken_at = ServerStat.maximum(:taken_at, :conditions => { :cluster_id => @provider_account.cluster_ids })
    @server_stats = ServerStat.find_all_by_cluster_id_and_taken_at(@provider_account.cluster_ids, latest_taken_at, :include => [:instance_vm_type, :cluster, :server])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @latest_stat_record }
      format.js   { render :partial => 'stats/list', :layout => false }
    end
  end

end
