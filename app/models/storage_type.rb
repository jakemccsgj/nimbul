class StorageType < BaseModel
    belongs_to :provider
    has_and_belongs_to_many :instance_vm_types, :order => 'position'

    validates_presence_of :api_name, :name
    validates_uniqueness_of :api_name, :name, :scope => :provider_id
end
