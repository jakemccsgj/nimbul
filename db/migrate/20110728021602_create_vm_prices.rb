class CreateVmPrices < ActiveRecord::Migration
  def self.up
    create_table :vm_prices do |t|
      t.integer :provider_id
      t.integer :vm_price_type_id
      t.integer :region_id
      t.integer :instance_vm_type_id
      t.integer :vm_os_type_id
      t.string :price_unit
      t.string :price_period
      t.integer :position

      t.timestamps
    end
    add_column :vm_prices, :price, :decimal, :precision => 8, :scale => 4
    add_index :vm_prices, :provider_id
    add_index :vm_prices, :vm_price_type_id
    add_index :vm_prices, :region_id
    add_index :vm_prices, :instance_vm_type_id
    add_index :vm_prices, :vm_os_type_id
  end

  def self.down
    drop_table :vm_prices
  end
end
