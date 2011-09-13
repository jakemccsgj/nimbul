class CreateLoadBalancerPolicies < ActiveRecord::Migration
  def self.up
    create_table :load_balancer_policies do |t|
      t.integer :load_balancer_id
      t.string :type
      t.string :policy_name
      t.string :cookie_name
      t.float :cookie_expiration_period

      t.timestamps
    end
  end

  def self.down
    drop_table :load_balancer_policies
  end
end
