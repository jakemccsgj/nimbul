class MigrateLaunchConfigurationsToUseVmTypes < ActiveRecord::Migration
  def self.up
    add_column :launch_configurations, :instance_vm_type_id, :integer
    add_index :launch_configurations, :instance_vm_type_id

    InstanceVmType.find(:all).each do |instance_vm_type|
      LaunchConfiguration.update_all(
        ['instance_vm_type_id = ?', instance_vm_type.id],
        ['instance_type = ? and provider_account_id in (select id from provider_accounts where provider_id = ?)', instance_vm_type.api_name, instance_vm_type.provider_id]
      )
    end

    remove_column :launch_configurations, :instance_type
  end

  def self.down
    add_column :launch_configurations, :instance_type, :string
    add_index :launch_configurations, :instance_type

    InstanceVmType.find(:all).each do |instance_vm_type|
      LaunchConfiguration.update_all(
        ['instance_type = ?', instance_vm_type.api_name],
        ['instance_vm_type_id = ?', instance_vm_type.id]
      )
    end
  end
end
