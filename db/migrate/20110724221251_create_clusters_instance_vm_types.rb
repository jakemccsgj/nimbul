class CreateClustersInstanceVmTypes < ActiveRecord::Migration
  def self.up
    create_table :clusters_instance_vm_types, :id => false do |t|
      t.integer :cluster_id, :instance_vm_type_id
    end
  end

  def self.down
    drop_table :clusters_instance_vm_types
  end
end
