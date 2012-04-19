class AddExtraFieldsToServerImages < ActiveRecord::Migration
  def self.up
    add_column :server_images, :image_type_id, :integer
    add_column :server_images, :platform, :string
    add_column :server_images, :state_reason_type_id, :integer
    add_column :server_images, :image_owner_alias, :string
    add_column :server_images, :description, :string
    add_column :server_images, :storage_type_id, :integer
    add_column :server_images, :root_device_name, :string
    add_column :server_images, :block_device_mapping_id, :integer
    add_column :server_images, :virtualizaton_type_id, :integer
    add_column :server_images, :hipervisor_id, :integer
  end

  def self.down
    remove_column :server_images, :hipervisor_id
    remove_column :server_images, :virtualizaton_type_id
    remove_column :server_images, :block_device_mapping_id
    remove_column :server_images, :root_device_name
    remove_column :server_images, :storage_type_id
    remove_column :server_images, :description
    remove_column :server_images, :image_owner_alias
    remove_column :server_images, :state_reason_type_id
    remove_column :server_images, :platform
    remove_column :server_images, :image_type_id
  end
end
