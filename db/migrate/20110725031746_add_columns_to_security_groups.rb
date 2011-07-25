class AddColumnsToSecurityGroups < ActiveRecord::Migration
  def self.up
    add_column :security_groups, :api_name, :string
    add_index :security_groups, :api_name
    add_column :security_groups, :vpc_api_name, :string
    add_index :security_groups, :vpc_api_name
  end

  def self.down
    remove_column :security_groups, :vpc_api_name
    remove_column :security_groups, :api_name
  end
end
