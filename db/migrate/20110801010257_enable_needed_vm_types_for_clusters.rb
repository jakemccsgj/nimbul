class EnableNeededVmTypesForClusters < ActiveRecord::Migration
  def self.up
    Cluster.find(:all, :include => [ :instance_vm_types, { :servers => { :server_profile_revision => :instance_vm_type } }]).each do |cluster|
      cluster.servers.each do |server|
        server_vm_type = server.server_profile_revision.instance_vm_type
        unless cluster.instance_vm_types.include?(server_vm_type)
          cluster.instance_vm_types << server_vm_type
        end
      end 
    end
  end

  def self.down
  end
end
