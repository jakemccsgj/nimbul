class VmPriceType < ActiveRecord::Base
    belongs_to :provider

    has_many :vm_prices

    validates_presence_of :api_name, :name
    validates_uniqueness_of :api_name, :name, :scope => :provider_id
end
