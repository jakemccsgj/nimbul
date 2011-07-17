class AddApiNameToRegions < ActiveRecord::Migration
  def self.up
    rename_column :regions, :name, :api_name
    add_column :regions, :name, :string
    add_column :regions, :position, :integer
  end

  def self.down
    remove_column :regions, :name
    rename_column :regions, :api_name, :name
    remove_column :regions, :position
  end
end
