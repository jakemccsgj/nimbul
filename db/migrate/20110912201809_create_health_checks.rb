class CreateHealthChecks < ActiveRecord::Migration
  def self.up
    create_table :health_checks do |t|
      t.integer :load_balancer_id
      t.integer :healthy_threshold
      t.integer :interval
      t.string :target_protocol
      t.integer :target_port
      t.string :target_path
      t.integer :timeout
      t.integer :unhealthy_threshold

      t.timestamps
    end
    add_index :health_checks, :load_balancer_id
  end

  def self.down
    drop_table :health_checks
  end
end
