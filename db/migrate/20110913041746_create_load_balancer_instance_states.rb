class CreateLoadBalancerInstanceStates < ActiveRecord::Migration
  def self.up
    create_table :load_balancer_instance_states do |t|
      t.integer :load_balancer_id
      t.integer :instance_id
      t.string :state
      t.string :reason_code
      t.string :description

      t.timestamps
    end
    add_index :load_balancer_instance_states, :load_balancer_id
    add_index :load_balancer_instance_states, :instance_id
  end

  def self.down
    drop_table :load_balancer_instance_states
  end
end
