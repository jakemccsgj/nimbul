class ProviderAccountRegion < ActiveRecord::Base
    belongs_to :provider_account
    belongs_to :region
end
