class InstanceVmType < BaseModel
    belongs_to :provider
    belongs_to :io_profile
    has_and_belongs_to_many :cpu_profiles, :order => 'position'
    has_and_belongs_to_many :storage_types, :order => 'position'

    validates_presence_of :api_name, :name, :ram_gb, :cpu_units, :storage_gb
    validates_uniqueness_of :api_name, :name, :scope => :provider_id
    validates_numericality_of :ram_gb, :cpu_units, :storage_gb
    validate :has_io_profile?
    validate :has_cpu_profiles?
    validate :has_storage_types?

    def has_io_profile?
        errors.add_to_base "must have an IO profile defined" if self.io_profile.nil?
    end

    def has_cpu_profiles?
        errors.add_to_base "must support at least one CPU profile" if self.cpu_profiles.blank?
    end

    def has_storage_types?
        errors.add_to_base "must support at least one Storage Type" if self.storage_types.blank?
    end
end
