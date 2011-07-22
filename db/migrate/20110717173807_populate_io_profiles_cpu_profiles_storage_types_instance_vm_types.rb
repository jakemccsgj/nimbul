class PopulateIoProfilesCpuProfilesStorageTypesInstanceVmTypes < ActiveRecord::Migration
  def self.up
io_profiles = [
[1, 'Low', ''],	
[2, 'Moderate', ''],		
[3, 'High', ''],		
[4, 'Very High', '10 Gigabit Ethernet'],
]
    io_profiles.each do |a|
      i = IoProfile.create({ :position => a[0], :name => a[1], :desc => a[2] })
    end

cpu_profiles = [
[1, '32-bit platform', 'i386'],
[2, '64-bit platform', 'x86_64'],
]
    cpu_profiles.each do |a|
      i = CpuProfile.create({ :position => a[0], :name => a[1], :api_name => a[2] })
    end

    provider = Provider.find_by_adapter_class('Ec2Adapter', :include => [:storage_types, :instance_vm_types])

storage_types = [
[1, 'instance-store', 'instance storage'],
[2, 'ebs', 'EBS storage'],
]
    storage_types.each do |a|
      i = provider.storage_types.build({ :position => a[0], :api_name => a[1], :name => a[2] })
      i.save
    end

vm_types = [
[1, 't1.micro', 'Micro Instance', 0.613, 2.0, 0, IoProfile.find_by_name('Low').id],
[2, 'm1.small', 'Small Instance', 1.7, 1.0, 160, IoProfile.find_by_name('Moderate').id],
[3, 'm1.large', 'Large Instance', 7.5, 4.0, 850, IoProfile.find_by_name('High').id],
[4, 'm1.xlarge', 'Extra Large Instance', 15.0, 8.0, 1690, IoProfile.find_by_name('High').id],
[5, 'm2.xlarge', 'High-Memory Extra Large Instance', 17.1, 6.5, 420, IoProfile.find_by_name('Moderate').id],
[6, 'm2.2xlarge', 'High-Memory Double Extra Large Instance', 34.2, 13.0, 850, IoProfile.find_by_name('High').id],
[7, 'm2.4xlarge', 'High-Memory Quadruple Extra Large Instance', 68.4, 26.0, 1690, IoProfile.find_by_name('High').id],
[8, 'c1.medium', 'High-CPU Medium Instance', 1.7, 5.0, 350, IoProfile.find_by_name('Moderate').id],
[9, 'c1.xlarge', 'High-CPU Extra Large Instance', 7.0, 20.0, 1690, IoProfile.find_by_name('High').id],
[10, 'cc1.4xlarge', 'Cluster Compute Quadruple Extra Large Instance', 23.0, 33.5, 1690, IoProfile.find_by_name('Very High').id],
[11, 'cg1.4xlarge', 'Cluster GPU Quadruple Extra Large Instance', 22.0, 33.5, 1690, IoProfile.find_by_name('Very High').id],
]
i386_vm_types = [ 't1.micro', 'm1.small', 'c1.medium'  ]
x86_64_vm_types = vm_types.collect{ |t| t[1] unless t[1] == 'm1.small' or t[1] == 'c1.medium'}.compact
    vm_types.each do |a|
      i = provider.instance_vm_types.build({
        :position => a[0], :api_name => a[1], :name => a[2], :ram_gb => a[3], :cpu_units => a[4], :storage_gb => a[5], :io_profile_id => a[6]
      })
      i.storage_types << StorageType.find_by_provider_id_and_api_name(provider.id, 'instance-store') unless i.api_name == 't1.micro'
      i.storage_types << StorageType.find_by_provider_id_and_api_name(provider.id, 'ebs')
      i.cpu_profiles << CpuProfile.find_by_api_name('i386') if i386_vm_types.include?(i.api_name)
      i.cpu_profiles << CpuProfile.find_by_api_name('x86_64') if x86_64_vm_types.include?(i.api_name)
      i.save
    end
  end

  def self.down
    IoProfile.delete_all
    CpuProfile.delete_all
    provider = Provider.find_by_adapter_class('Ec2Adapter', :include => [:storage_types, :instance_vm_types])
    provider.storage_types.delete_all if provider
    provider.instance_vm_types.delete_all if provider
  end
end
