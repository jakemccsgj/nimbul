class AddInstancePortAndSslCertificateIdToLoadBalancerListeners < ActiveRecord::Migration
  def self.up
    add_column :load_balancer_listeners, :instance_protocol, :string
    add_column :load_balancer_listeners, :s_s_l_certificate_id, :string
  end

  def self.down
    remove_column :load_balancer_listeners, :s_s_l_certificate_id
    remove_column :load_balancer_listeners, :instance_protocol
  end
end
