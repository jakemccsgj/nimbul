class ReservedInstance < BaseModel
    belongs_to :provider_account
    belongs_to :zone
    belongs_to :instance_vm_type

    def instance_type
        return nil if self.instance_vm_type.nil?
        return self.instance_vm_type.api_name
    end
end
