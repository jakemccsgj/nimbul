class AddIndexToCloudResources < ActiveRecord::Migration
  def self.up
    add_index :cloud_resources, [:cloud_id, :type], :name => :index_cloud_resources_on_cloud_id_and_type
  end

  def self.down
    remove_index :cloud_resources, :index_cloud_resources_on_cloud_id_and_type
  end
end
