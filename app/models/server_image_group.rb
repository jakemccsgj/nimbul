class ServerImageGroup < ActiveRecord::Base
    belongs_to :provider_account
    belongs_to :server_image_category

    has_and_belongs_to_many :server_images, :uniq => true

    validates_presence_of :provider_account_id
    validates_presence_of :server_image_category_id
    validates_presence_of :name
    validates_uniqueness_of :name, :scope => :provider_account_id
end
