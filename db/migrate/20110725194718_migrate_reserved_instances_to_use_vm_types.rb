class MigrateReservedInstancesToUseVmTypes < ActiveRecord::Migration
  def self.up
    add_column :reserved_instances, :instance_vm_type_id, :integer
    add_index :reserved_instances, :instance_vm_type_id

    InstanceVmType.find(:all).each do |instance_vm_type|
      ReservedInstance.update_all(
        ['instance_vm_type_id = ?', instance_vm_type.id],
        ['instance_type = ?', instance_vm_type.api_name]
      )
    end

    remove_column :reserved_instances, :instance_type
  end

  def self.down
    add_column :reserved_instances, :instance_type, :string
    add_index :reserved_instances, :instance_type

    InstanceVmType.find(:all).each do |instance_vm_type|
      ReservedInstance.update_all(
        ['instance_type = ?', instance_vm_type.api_name],
        ['instance_vm_type_id = ?', instance_vm_type.id]
      )
    end

    remove_column :reserved_instances, :instance_vm_type_id
  end
end
