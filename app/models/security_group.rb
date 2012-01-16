class SecurityGroup < BaseModel
    belongs_to :provider_account
    validates_presence_of :name
    validates_uniqueness_of :name, :scope => :provider_account_id

    has_and_belongs_to_many :instances, :uniq => true
    has_and_belongs_to_many :servers
    has_and_belongs_to_many :firewall_rules
    has_and_belongs_to_many :users

    attr_accessor :should_destroy, :status_message

    def should_destroy?
        should_destroy.to_i == 1
    end

    # sort, search and paginate parameters
    def self.per_page
       10
    end

    def self.sort_fields
        %w(api_name name description)
    end

    def self.search_fields
        %w(api_name name description)
    end
    
    def self.search_by_firewall_rule(firewall_rule, search, options={})
        extra_joins = options[:joins]
        extra_conditions = options[:conditions]

        joins = [
            'INNER JOIN firewall_rules_security_groups ON firewall_rules_security_groups.security_group_id = security_groups.id'
        ]
        joins = joins + extra_joins unless extra_joins.blank?
        conditions = [ 'firewall_rules_security_groups.firewall_rule_id = ?', (firewall_rule.is_a?(FirewallRule) ? firewall_rule.id : firewall_rule) ]
        unless extra_conditions.blank?
            extra_conditions = [ extra_conditions ] if not extra_conditions.is_a? Array
            conditions[0] << ' AND ' + extra_conditions[0];
            conditions << extra_conditions[1..-1]
        end
        
        options[:joins] = joins
        options[:conditions] = conditions

        search(search, options)
    end
  
    def self.search_by_provider_account(provider_account, search, options={})
        extra_joins = options[:joins]
        extra_conditions = options[:conditions]

        joins = []
        joins = joins + extra_joins unless extra_joins.blank?
        conditions = [ 'provider_account_id = ?', (provider_account.is_a?(ProviderAccount) ? provider_account.id : provider_account) ]
        unless extra_conditions.blank?
            extra_conditions = [ extra_conditions ] if not extra_conditions.is_a? Array
            conditions[0] << ' AND ' + extra_conditions[0];
            conditions << extra_conditions[1..-1]
        end
        
        options[:joins] = joins
        options[:conditions] = conditions

        search(search, options)
    end
end
