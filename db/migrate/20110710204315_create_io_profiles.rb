class CreateIoProfiles < ActiveRecord::Migration
  def self.up
    create_table :io_profiles do |t|
      t.integer :position
      t.string :name
      t.string :desc

      t.timestamps
    end
  end

  def self.down
    drop_table :io_profiles
  end
end
