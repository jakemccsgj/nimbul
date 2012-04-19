class DropInstanceAllocationRecords < ActiveRecord::Migration
  def self.up
    drop_table :instance_allocation_records
  end

  def self.down
  end
end
