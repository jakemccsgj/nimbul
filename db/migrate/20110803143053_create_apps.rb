class CreateApps < ActiveRecord::Migration
  def self.up
    create_table :apps do |t|
      t.integer :account_group_id
      t.string :api_name
      t.string :name
      t.text :description
      t.integer :position

      t.timestamps
    end
    add_index :apps, :account_group_id
    add_index :apps, :api_name
    add_column :clusters, :app_id, :integer
    add_index :clusters, :app_id
  end

  def self.down
    remove_column :clusters, :app_id, :index
    drop_table :apps
  end
end
