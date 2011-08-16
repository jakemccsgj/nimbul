class CreateCpuProfilesInstanceVmTypes < ActiveRecord::Migration
  def self.up
    create_table :cpu_profiles_instance_vm_types, :id => false do |t|
      t.integer :cpu_profile_id, :instance_vm_type_id
    end
    add_index :cpu_profiles_instance_vm_types, :cpu_profile_id
    add_index :cpu_profiles_instance_vm_types, :instance_vm_type_id
  end

  def self.down
    drop_table :cpu_profiles_instance_vm_types
  end
end
