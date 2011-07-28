class CreateOsTypes < ActiveRecord::Migration
  def self.up
    create_table :os_types do |t|
      t.integer :position
      t.string :api_name
      t.string :name
      t.text :desc

      t.timestamps
    end
    add_index :os_types, :api_name
  end

  def self.down
    drop_table :os_types
  end
end
