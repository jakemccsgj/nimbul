class VmOsType < ActiveRecord::Base
    belongs_to :provider
    belongs_to :os_type

    has_many :vm_prices, :dependent => :nullify, :order => :position

    validates_presence_of :os_type_id, :api_name, :name
    validates_uniqueness_of :api_name, :name, :scope => :provider_id
end
