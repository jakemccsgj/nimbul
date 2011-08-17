require 'aasm'

class ServerImage < BaseModel
    include AASM
    belongs_to :provider_account
    belongs_to :cpu_profile
    belongs_to :storage_type

    has_many :server_profile_revisions, :dependent => :nullify
    has_many :launch_configurations, :dependent => :nullify

    has_and_belongs_to_many :server_image_groups, :uniq => true

    set_inheritance_column :server_image_type

    validates_presence_of :name
    validates_uniqueness_of :name, :scope => :provider_account_id
    validates_uniqueness_of :image_id, :scope => :provider_account_id, :message => 'There is already an Image with this AMI ID.'
    validates_presence_of :image_id, :if => :image_id_and_location_are_blank, :message => 'You have to specify AMI ID (existing Images) or a Manifest Path (new Images)'
    validates_presence_of :location, :if => :image_id_and_location_are_blank, :message => 'You have to specify AMI ID (existing Images) or a Manifest Path (new Images)'
    
    attr_accessor :should_destroy, :status_message, :destroyed
    
    after_destroy :mark_as_destroyed

    def destroy
        unless server_profile_revisions.empty?
            errors.add_to_base "has Server Profile(s) associated with it. Please associate the Server Profile(s) with a different Server Image before removing this Server Image."
            return false
        end
        super
    end
    
    def image_id_and_location_are_blank
        self.image_id.blank? and self.location.blank?
    end
    
    def mark_as_destroyed
        self.destroyed = true
    end
    
    def should_destroy?
        should_destroy.to_i == 1
    end

    def architecture
        return nil if cpu_profile.nil?
        return cpu_profile.api_name
    end

    def enable!
        update_attribute(:is_enabled, true)
    end

    def disable!
        if self.server_profile_revisions.empty?
            update_attribute(:is_enabled, false)
        else
            self.errors.add(:is_enabled, "Can't disable '#{self.name}' - there are server profiles using this server image.")
        end
    end

    # aasm
    aasm_column :state
    aasm_initial_state :unknown
    aasm_state :unknown
    aasm_state :available
    aasm_state :unavailable

    aasm_event :state_unknown do
        transitions :from => [ :unknown, :available, :unavailable ], :to => :unknown
    end

    aasm_event :make_available do
        transitions :from => [ :unknown, :available, :unavailable ], :to => :available
    end

    aasm_event :make_unavailable do
        transitions :from => [ :unknown, :available, :unavailable ], :to => :unavailable
    end
    
    def belongs_to_provider_account?(provider_account)
        account_id = provider_account.is_a?(ProviderAccount) ? provider_account.account_id : provider_account
        !self.owner_id.blank? and ( self.owner_id == account_id )
    end

    # fill out attributes from the Provider Account (e.g. when registering a new image
    def self.refresh(server_image)
        Ec2Adapter.refresh_server_image(server_image)
    end

    def self.options_for_find_by_user(user, options={})
        extra_joins = options[:joins]
        extra_conditions = options[:conditions]
        order = options[:order]

        conditions = ['1=0']
        if user.has_role?("admin")
            joins = []
            conditions = []
        else
            joins = []
            local_conditions = ['1=0']
            clusters = Cluster.find_all_by_user(user)
            unless clusters.empty?
                local_conditions << table_name()+".provider_account_id IN (#{clusters.collect{|c| c.provider_account_id}.uniq.join(',')})"
            end
            conditions[0] = "(#{local_conditions.join(' OR ')})"
        end
    
        joins = joins + extra_joins unless extra_joins.blank?

        unless extra_conditions.blank?
            extra_conditions = [ extra_conditions ] if not extra_conditions.is_a? Array
            conditions[0] << ' AND ' + extra_conditions[0]
            conditions << extra_conditions[1..-1]
        end
    
        order = table_name()+'.name' if order.blank?

        options.merge!({
            :joins => joins,
            :conditions => conditions,
            :order => order,
        })

        return options        
    end

    def self.search_by_provider_account(provider_account, search, page, extra_joins, extra_conditions, sort = nil, filter=nil, include=nil)
        joins = []
        joins = joins + extra_joins unless extra_joins.blank?

        conditions = [ 'provider_account_id = ?', (provider_account.is_a?(ProviderAccount) ? provider_account.id : provider_account) ]
        unless extra_conditions.blank?
            extra_conditions = [ extra_conditions ] if not extra_conditions.is_a? Array
            conditions[0] << ' AND ' + extra_conditions[0];
            conditions << extra_conditions[1..-1]
        end
        
        search(search, page, joins, conditions, sort, filter, include)
    end
    
    def allocate!
        #begin
            if self.image_id
                Ec2Adapter.refresh_server_image(self)
            else
                Ec2Adapter.register_server_image(self)
            end
            self.save
        #rescue
        #    if self.location
        #        self.errors.add(:location, "#{$!}")
        #    else
        #        self.errors.add(:image_id, "#{$!}")
        #    end
        #    self.status_message = "Failed to add server image: #{$!}"
        #    self.destroy
        #    return false
        #end
        return true
    end

    def release!
        begin
            if self.destroy
              Ec2Adapter.deregister_server_image(self)
            end
        rescue
            self.errors.add(:id, "#{$!}")
            self.status_message = "Failed to deregister server image: #{$!}"
            return false
        end
        return true
    end

    def self.per_page
        10
    end

    def self.sort_fields
        %w(name image_id storage_type_id location cpu_profile_id state owner_id is_public is_enabled provider_account_id)
    end

    def self.search_fields
        %w(name image_id location)
    end

end
