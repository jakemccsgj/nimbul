class AddIoProfileIdToInstanceVmTypes < ActiveRecord::Migration
  def self.up
    add_column :instance_vm_types, :io_profile_id, :integer
  end

  def self.down
    remove_column :instance_vm_types, :io_profile_id
  end
end
