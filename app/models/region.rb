class Region < BaseModel
    belongs_to :provider
    has_many :zones

    validates_presence_of :provider_id, :api_name, :name, :endpoint_url
    validates_uniqueness_of :api_name, :name, :scope => :provider_id

    serialize :meta_data, Hash
end
