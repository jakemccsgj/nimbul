class Region < BaseModel
    belongs_to :provider

    has_many :provider_account_regions
    has_many :provider_accounts, :through => :provider_account_regions, :order => :name

    has_many :zones, :order => :name, :dependent => :nullify

    validates_presence_of :provider_id, :api_name, :name, :endpoint_url
    validates_uniqueness_of :api_name, :name, :scope => :provider_id

    serialize :meta_data, Hash
end
