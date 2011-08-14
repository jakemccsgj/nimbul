class AddServerImageIdToServerProfileRevisions < ActiveRecord::Migration
  class ProviderAccount < BaseModel
    has_many :server_images
    has_many :server_profiles
  end
  class ServerImage < BaseModel
    belongs_to :provider_account 
    has_many :server_profile_revisions
  end
  class ServerProfile < BaseModel
    belongs_to :provider_account
    has_many :server_profile_revisions, :dependent => :destroy
  end
  class ServerProfileRevision < BaseModel
    belongs_to :server_profile
    belongs_to :server_image
  end

  def self.up
    add_column :server_profile_revisions, :server_image_id, :integer
    add_index :server_profile_revisions, :server_image_id
    ServerProfileRevision.find(:all, :include => {
      :server_profile => { :provider_account => :server_images}
    }).each do |spr|
      if spr.server_profile.provider_account.nil?
        spr.server_profile.destroy
      else
        server_image = spr.server_profile.provider_account.server_images.detect{|si| si.image_id == spr.image_id}
        spr.update_attribute(:server_image_id, server_image.id) unless server_image.nil?
      end
    end
    remove_column :server_profile_revisions, :image_id
  end

  def self.down
    add_column :server_profile_revisions, :image_id, :string
    add_index :server_profile_revisions, :image_id
    ServerProfileRevision.find(:all, :include => :server_image).each do |spr|
      spr.update_attribute(:image_id, server_image.image_id) unless server_image.nil?
    end
    remove_column :server_profile_revisions, :server_image_id
  end
end
