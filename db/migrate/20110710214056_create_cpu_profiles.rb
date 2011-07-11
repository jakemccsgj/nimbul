class CreateCpuProfiles < ActiveRecord::Migration
  def self.up
    create_table :cpu_profiles do |t|
      t.integer :position
      t.string :name
      t.string :api_name
      t.string :desc

      t.timestamps
    end
  end

  def self.down
    drop_table :cpu_profiles
  end
end
