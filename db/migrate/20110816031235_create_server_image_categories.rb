class CreateServerImageCategories < ActiveRecord::Migration
  def self.up
    create_table :server_image_categories do |t|
      t.integer :provider_account_id
      t.string :name
      t.integer :position

      t.timestamps
    end
    add_index :server_image_categories, :provider_account_id
  end

  def self.down
    drop_table :server_image_categories
  end
end
