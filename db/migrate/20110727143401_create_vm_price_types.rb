class CreateVmPriceTypes < ActiveRecord::Migration
  def self.up
    create_table :vm_price_types do |t|
      t.integer :provider_id
      t.string :api_name
      t.string :name
      t.text :desc
      t.integer :position

      t.timestamps
    end
    add_index :vm_price_types, :provider_id
    add_index :vm_price_types, :api_name
  end

  def self.down
    drop_table :vm_price_types
  end
end
