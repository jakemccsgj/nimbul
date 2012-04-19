class AddInstanceVmTypeIdToInstances < ActiveRecord::Migration
  def self.up
    add_column :instances, :instance_vm_type_id, :integer
    add_index :instances, :instance_vm_type_id
  end

  def self.down
    remove_column :instances, :instance_vm_type_id
  end
end
