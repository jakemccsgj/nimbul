class AddExtraFieldsToInstances < ActiveRecord::Migration
  def self.up
    add_column :instances, :platform, :string
    add_column :instances, :monitoring, :string
    add_column :instances, :subnet_id, :string
    add_column :instances, :vpc_id, :string
    add_column :instances, :cpu_profile_id, :integer
    add_column :instances, :storage_type_id, :integer
    add_column :instances, :root_device_name, :string
    add_index :instances, :cpu_profile_id
    add_index :instances, :storage_type_id
    add_index :instances, :root_device_name
  end

  def self.down
    remove_column :instances, :root_device_name
    remove_column :instances, :storage_type_id
    remove_column :instances, :cpu_profile_id
    remove_column :instances, :vpc_id
    remove_column :instances, :subnet_id
    remove_column :instances, :monitoring
    remove_column :instances, :platform
  end
end
