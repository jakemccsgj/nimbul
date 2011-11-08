class CreateServerStats < ActiveRecord::Migration
  def self.up
    create_table :server_stats do |t|
      t.integer :cluster_id
      t.integer :server_id
      t.string :instance_type
      t.integer :instance_count
      t.datetime :taken_at

      t.timestamps
    end
    add_index :server_stats, [ :cluster_id, :server_id, :taken_at ]
    add_index :server_stats, :server_id
    add_index :server_stats, :instance_type
    add_index :server_stats, :taken_at
  end

  def self.down
    drop_table :server_stats
  end
end
