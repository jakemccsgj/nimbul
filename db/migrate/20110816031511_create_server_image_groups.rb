class CreateServerImageGroups < ActiveRecord::Migration
  def self.up
    create_table :server_image_groups do |t|
      t.integer :provider_account_id
      t.integer :server_image_category_id
      t.string :name
      t.text :description
      t.integer :position

      t.timestamps
    end
    add_index :server_image_groups, :provider_account_id
    add_index :server_image_groups, :server_image_category_id
  end

  def self.down
    drop_table :server_image_groups
  end
end
