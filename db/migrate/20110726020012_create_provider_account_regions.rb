class CreateProviderAccountRegions < ActiveRecord::Migration
  def self.up
    create_table :provider_account_regions do |t|
      t.integer :provider_account_id
      t.integer :region_id
      t.integer :position

      t.timestamps
    end
    add_index :provider_account_regions, :provider_account_id
    add_index :provider_account_regions, :region_id
  end

  def self.down
    drop_table :provider_account_regions
  end
end
