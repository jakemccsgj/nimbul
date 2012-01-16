require 'aasm'

class LaunchConfiguration < BaseModel
    include AASM

    belongs_to :provider_account
    belongs_to :server
    belongs_to :server_profile_revision
    belongs_to :server_image
    belongs_to :instance_vm_type
    
    has_and_belongs_to_many :security_groups
    has_many :auto_scaling_groups, :dependent => :destroy
    has_many :block_device_mappings, :dependent => :destroy

    # auditing
    has_many :audit_logs, :as => :auditable, :dependent => :nullify
 
    validates_presence_of :name, :image_id, :instance_vm_type_id
    validates_associated :block_device_mappings

    before_create :assign_cloud_resource_id
    after_update :save_block_device_mappings

    attr_accessor :should_destroy, :status_message

    aasm_column :state
    aasm_initial_state :disabled
    aasm_state :disabled
    aasm_state :active

    aasm_event :activate do
        transitions :from => [ :disabled ], :to => :active, :guard => :cloud_activate?
    end

    aasm_event :disable do
        transitions :from => [ :active ], :to => :disabled, :guard => :cloud_disable?
    end

    include TrackChanges # must follow any before filters

    def instance_type
        return nil if self.instance_vm_type.nil?
        return self.instance_vm_type.api_name
    end

    def assign_cloud_resource_id
        if self.launch_configuration_name.blank?
            chars = ("a".."f").to_a + ("0".."9").to_a
            n = "lc-"
            1.upto(8) { |i| n << chars[rand(chars.size-1)] }
            self.launch_configuration_name = n
        end
    end

    def locked?() auto_scaling_groups.select{ |asg| asg.active? }.length > 0; end
    def unlocked?() !locked?; end

    def cloud_activate?()
        return AsAdapter.create_launch_configuration(self)
    end

    def cloud_disable?()
    # don't allow disabling if there are any auto scaling groups
    # currently active that are using this launch configuration
    # force the user to disable all auto scaling groups first
        return unlocked? && AsAdapter.delete_launch_configuration(self)
    end

    def should_destroy?
        should_destroy.to_i == 1
    end
    
    def save_block_device_mappings
        block_device_mappings.each do |i|
            if i.should_destroy?
                i.destroy
            else
                i.save(false)
            end
        end
    end

    def block_device_mapping_attributes=(block_device_mapping_attributes)
        block_device_mapping_attributes.each do |attributes|
            if attributes[:id].blank?
                block_device_mappings.build(attributes)
            else
                block_device_mapping = block_device_mappings.detect { |c| c.id == attributes[:id].to_i }
                block_device_mapping.attributes = attributes
            end
        end
    end

    def find_similar_servers
      options ={
        :include => :servers
      }
      si = ServerImage.find_by_provider_account_id_and_image_id(self.provider_account_id, self.image_id, options)
      return (si.nil? ? [] : si.servers)
    end
    
    def self.search_by_provider_account(provider_account, search, options={})
        extra_joins = options[:joins]
        extra_conditions = options[:conditions]

        joins = extra_joins
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

    # sort, search and paginate parameters
    def self.per_page
        10
    end

    def self.sort_fields
        %w(launch_configuration_name name image_id instance_vm_type_id created_time server_id state)
    end

    def self.search_fields
        %w(launch_configuration_name name image_id state)
    end

end
