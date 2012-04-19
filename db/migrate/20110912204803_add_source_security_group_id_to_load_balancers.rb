class AddSourceSecurityGroupIdToLoadBalancers < ActiveRecord::Migration
  def self.up
    add_column :load_balancers, :source_security_group_id, :integer
    add_index :load_balancers, :source_security_group_id
  end

  def self.down
    remove_column :load_balancers, :source_security_group_id
  end
end
