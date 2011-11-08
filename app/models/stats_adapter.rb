class StatsAdapter
    def self.frequency
        1.hour
    end

    def self.refresh_account(provider_account)
	f = frequency() 
        current_bucket = Time.at((Time.now.to_f / f).ceil * f).utc

        latest_stats = ServerStat.find_by_sql([
            'select s.cluster_id as cluster_id, i.server_id, i.instance_vm_type_id, count(i.id) as instance_count '+
            'from servers s, instances i where s.id = i.server_id and i.provider_account_id = :provider_account_id '+
            'group by cluster_id, server_id',
            { :provider_account_id => provider_account.id }
        ])

        latest_stats.each do |s|
            r = ServerStat.find(:first, :conditions => [
                'cluster_id=:cluster_id AND server_id=:server_id AND instance_vm_type_id=:instance_vm_type_id AND taken_at=:taken_at',
                { :cluster_id => s.cluster_id, :server_id => s.server_id, :instance_vm_type_id => s.instance_vm_type_id, :taken_at => current_bucket }
            ])
            if r.nil?
                r = s.clone
                r.taken_at = current_bucket
                r.save
            elsif s.instance_count > r.instance_count
                r.update_attribute(:instance_count, s.instance_count)
            end
        end
    end
end
