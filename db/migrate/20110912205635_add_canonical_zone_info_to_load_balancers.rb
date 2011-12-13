class AddCanonicalZoneInfoToLoadBalancers < ActiveRecord::Migration
  def self.up
    add_column :load_balancers, :canonical_hosted_zone_name, :string
    add_column :load_balancers, :canonical_hosted_zone_name_id, :string
  end

  def self.down
    remove_column :load_balancers, :canonical_hosted_zone_name_id
    remove_column :load_balancers, :canonical_hosted_zone_name
  end
end
