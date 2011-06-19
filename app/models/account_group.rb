class AccountGroup < ActiveRecord::Base
    validates_presence_of :name
    has_many :provider_accounts, :validate => false
    after_save :save_invalid_provider_accounts

    def save_invalid_provider_accounts
        self.provider_accounts.each do |pa|
            pa.save(false)
        end
    end
end
