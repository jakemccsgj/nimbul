class ServerStat < ActiveRecord::Base
    belongs_to :instance_vm_type, :include => :vm_prices
    belongs_to :cluster
    belongs_to :server

    attr_accessor :zone
    def count
        instance_count
    end

    def instance_type
        return nil if self.instance_vm_type.nil?
        return self.instance_vm_type.api_name
    end

    def vm_prices
        return [] if instance_vm_type.nil?
        return instance_vm_type.vm_prices
    end

    def server_cost
        return nil if vm_prices.empty?
        price = vm_prices[0].price
        (instance_count*price)
    end

    attr_accessor :cluster_cost
    attr_accessor :server_count
end
