class CreateVmOsTypes < ActiveRecord::Migration
  def self.up
    create_table :vm_os_types do |t|
      t.integer :provider_id
      t.integer :os_type_id
      t.string :api_name
      t.string :name
      t.text :desc
      t.integer :position

      t.timestamps
    end
    add_index :vm_os_types, :provider_id
    add_index :vm_os_types, :os_type_id
    add_index :vm_os_types, :api_name
  end

  def self.down
    drop_table :vm_os_types
  end
end
