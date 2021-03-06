class VmPrice < ActiveRecord::Base
    belongs_to :provider
    belongs_to :vm_price_type
    belongs_to :region
    belongs_to :instance_vm_type
    belongs_to :vm_os_type

    validates_presence_of :provider_id, :vm_price_type_id, :region_id
    validates_presence_of :instance_vm_type_id, :vm_os_type_id
    validates_presence_of :price, :price_unit, :price_period
    validates_numericality_of :price
    validates_uniqueness_of :vm_price_type_id, :scope => [ :provider_id, :region_id, :instance_vm_type_id, :vm_os_type_id ], :message => 'the combination of Type, Region, VM Type and Operating System should be unique'
end
