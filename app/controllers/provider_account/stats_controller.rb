class ProviderAccount::StatsController < ApplicationController
    before_filter :login_required
    require_role  :admin,
	:unless => "current_user.has_provider_account_access?(ProviderAccount.find(params[:provider_account_id])) "

    def index
        @provider_account = ProviderAccount.find(params[:provider_account_id], :include => [ :clusters, :reserved_instances, :zones, :account_group ])
        @zones = @provider_account.zones

        if @provider_account.account_group.nil?
            @reserved_instances = @provider_account.reserved_instances
            @running_instances = @provider_account.instances.select{|instance| instance.running?}
        else
            @account_group = @provider_account.account_group
            @reserved_instances = ReservedInstance.find_by_sql([
                'select zone_id, instance_type, sum(count) as count, usage_price from reserved_instances '+
                'where provider_account_id in (select id from provider_accounts where account_group_id=:account_group_id) '+
                'group by zone_id, instance_type, usage_price '+
                'order by usage_price',
                { :account_group_id => @provider_account.account_group_id }
            ])
            @running_instances = ReservedInstance.find_by_sql([
                'select z.name as zone, instance_type, count(i.id) as count from instances i, zones z '+
                'where i.zone_id = z.id and '+
                'i.provider_account_id in (select id from provider_accounts where account_group_id=:account_group_id) '+
                'group by zone, instance_type '+
                'order by z.name',
                { :account_group_id => @provider_account.account_group_id }
            ])
        end

        @cluster_names = @provider_account.clusters.collect{|a| a.name}.sort
        @cluster_names << ''
        @latest_stat_record = StatRecord.find_by_provider_account_id(@provider_account.id, :order => 'taken_at DESC', :include => :instance_allocation_records)
        @zone_type_stats = Hash.new()

        # make sure reserved instances show up in the Allocation Table
        @reserved_instances.each do |ri|
            @zone_type_stats[ri.zone_id] = Hash.new  unless @zone_type_stats[ri.zone_id]
            @zone_type_stats[ri.zone_id].store(ri.instance_type, Hash.new) unless @zone_type_stats[ri.zone_id][ri.instance_type]
            @zone_type_stats[ri.zone_id].fetch(ri.instance_type).store('Total', 0)
        end

        # build Allocation Table
        unless @latest_stat_record.nil?
            @latest_stat_record.instance_allocation_records.each do |iar|
                @zone_type_stats[iar.zone_id] = Hash.new unless @zone_type_stats[iar.zone_id]
                @zone_type_stats[iar.zone_id].store(iar.instance_type, Hash.new) unless @zone_type_stats[iar.zone_id][iar.instance_type]
                current_value = @zone_type_stats[iar.zone_id][iar.instance_type]['Total'] || 0
                @zone_type_stats[iar.zone_id].fetch(iar.instance_type).store('Total', current_value + iar.running.to_i)
                current_cluster_value =  @zone_type_stats[iar.zone_id][iar.instance_type][iar.cluster_name] || 0
                @zone_type_stats[iar.zone_id].fetch(iar.instance_type).store(iar.cluster_name, current_cluster_value + iar.running.to_i)
            end
        end

        respond_to do |format|
            format.html
            format.xml  { render :xml => @latest_stat_record }
            format.js   { render :partial => 'stats/list', :layout => false }
        end
	end

end
