class ServerImageCategory < ActiveRecord::Base
    belongs_to :provider_account
    has_many :server_image_groups, :order => :position, :dependent => :destroy

    validates_presence_of :provider_account_id
    validates_presence_of :name
    validates_uniqueness_of :name, :scope => :provider_account_id
end
