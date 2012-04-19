class AddPositionToStorageTypes < ActiveRecord::Migration
  def self.up
    add_column :storage_types, :position, :integer
  end

  def self.down
    remove_column :storage_types, :position
  end
end
