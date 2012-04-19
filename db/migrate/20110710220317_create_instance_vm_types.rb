class CreateInstanceVmTypes < ActiveRecord::Migration
  def self.up
    create_table :instance_vm_types do |t|
      t.integer :position
      t.integer :provider_id
      t.string :name
      t.string :api_name
      t.text :desc
      t.float :ram_gb
      t.string :ram_type
      t.string :ram_desc
      t.float :cpu_units
      t.string :cpu_type
      t.string :cpu_desc
      t.integer :storage_gb
      t.string :storage_type
      t.string :storage_desc

      t.timestamps
    end
  end

  def self.down
    drop_table :instance_vm_types
  end
end
