class ServerStat < ActiveRecord::Base
    belongs_to :instance_vm_type
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
end
