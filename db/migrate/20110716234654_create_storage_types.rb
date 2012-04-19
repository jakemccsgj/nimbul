class CreateStorageTypes < ActiveRecord::Migration
  def self.up
    create_table :storage_types do |t|
      t.integer :provider_id
      t.string :api_name
      t.string :name
      t.string :desc

      t.timestamps
    end
  end

  def self.down
    drop_table :storage_types
  end
end
