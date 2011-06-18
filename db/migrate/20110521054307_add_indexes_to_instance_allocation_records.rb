class AddIndexesToInstanceAllocationRecords < ActiveRecord::Migration
  def self.up
    add_index :instance_allocation_records, [:cluster_id, :server_id]
    add_index :instance_allocation_records, :created_at
  end

  def self.down
    remove_index :instance_allocation_records, [:cluster_id, :server_id]
    remove_index :instance_allocation_records, :created_at
  end
end
