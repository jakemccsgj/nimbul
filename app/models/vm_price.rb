class VmPrice < ActiveRecord::Base
    belongs_to :provider
    belongs_to :vm_price_type
    belongs_to :region
    belongs_to :instance_vm_type
    belongs_to :vm_os_type

    validates_presence_of :api_name, :name
    validates_uniqueness_of :api_name, :name, :scope => :provider_id
end
