class CreateInstanceVmTypesStorageTypes < ActiveRecord::Migration
  def self.up
    create_table :instance_vm_types_storage_types, :id => false do |t|
      t.integer :instance_vm_type_id, :storage_type_id
    end
  end

  def self.down
    drop_table :instance_vm_types_storage_types
  end
end
