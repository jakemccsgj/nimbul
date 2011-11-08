class MigrateServerStatsToUseVmTypes < ActiveRecord::Migration
  def self.up
    add_column :server_stats, :instance_vm_type_id, :integer
    add_index :server_stats, :instance_vm_type_id

    InstanceVmType.find(:all).each do |instance_vm_type|
      ServerStat.update_all(
        ['instance_vm_type_id = ?', instance_vm_type.id],
        ['instance_type = ?', instance_vm_type.api_name]
      )
    end

    remove_column :server_stats, :instance_type
  end

  def self.down
    add_column :server_stats, :instance_type, :string
    add_index :server_stats, :instance_type

    InstanceVmType.find(:all).each do |instance_vm_type|
      ServerStat.update_all(
        ['instance_type = ?', instance_vm_type.api_name],
        ['instance_vm_type_id = ?', instance_vm_type.id]
      )
    end

    remove_column :server_stats, :instance_vm_type_id
  end
end
