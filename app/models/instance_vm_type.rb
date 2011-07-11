class InstanceVmType < BaseModel
    belongs_to :provider

    validates_presence_of :name, :api_name
    validates_uniqueness_of :name, :api_name
end
