class AddLaunchConfigurationIdToBlockDeviceMappings < ActiveRecord::Migration
  def self.up
    add_column :block_device_mappings, :launch_configuration_id, :integer
    add_index :block_device_mappings, :launch_configuration_id
  end

  def self.down
    remove_column :block_device_mappings, :launch_configuration_id
  end
end
