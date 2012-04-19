class AccountGroup < ActiveRecord::Base
    has_many :provider_accounts, :include => :clusters, :validate => false, :dependent => :nullify
    has_many :apps, :validate => false, :dependent => :nullify, :order => :api_name

    after_save :save_invalid_provider_accounts

    validates_presence_of :name

    def save_invalid_provider_accounts
        self.provider_accounts.each do |pa|
            pa.save(false)
        end
    end

    def clusters
        return [] if provider_accounts.empty?
        Cluster.find_all_by_provider_account_id(provider_account_ids, :order => :name)
    end

    def cluster_ids
        clusters.collect{|c| c.id}
    end

    def can_use_more_of?(account_group_resource_type)
        return true if account_group_resource_type == 'App'
        return false
    end
end
