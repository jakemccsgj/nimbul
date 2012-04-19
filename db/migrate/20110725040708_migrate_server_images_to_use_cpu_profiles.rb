class MigrateServerImagesToUseCpuProfiles < ActiveRecord::Migration
  def self.up
    add_column :server_images, :cpu_profile_id, :integer
    add_index :server_images, :cpu_profile_id

    CpuProfile.find(:all).each do |cpu_profile|
      ServerImage.update_all(
        ['cpu_profile_id = ?', cpu_profile.id],
        ['architecture = ?', cpu_profile.api_name]
      )
    end

    remove_column :server_images, :architecture
  end

  def self.down
    add_column :server_images, :architecture, :string
    add_index :server_images, :architecture

    CpuProfile.find(:all).each do |cpu_profile|
      ServerImage.update_all(
        ['architecture = ?', cpu_profile.api_name],
        ['cpu_profile_id = ?', cpu_profile.id]
      )
    end

    remove_column :server_images, :cpu_profile_id
  end
end
