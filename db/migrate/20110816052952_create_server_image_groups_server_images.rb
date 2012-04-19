class CreateServerImageGroupsServerImages < ActiveRecord::Migration
  def self.up
    create_table :server_image_groups_server_images, :id => false do |t|
      t.integer :server_image_group_id, :server_image_id
    end
    add_index :server_image_groups_server_images, :server_image_group_id
    add_index :server_image_groups_server_images, :server_image_id
  end

  def self.down
    drop_table :server_image_groups_server_images
  end
end
