class PopulateOsTypesVmOsTypesVmPriceTypesVmPrices < ActiveRecord::Migration
  def self.up
os_types = [
['linux','Linux'],
['windows','Windows']
]
    os_types.each do |ot|
      if OsType.find_by_api_name(ot[0]).nil?
        OsType.create({
          :api_name => ot[0],
          :name => ot[1],
        })
      end
    end

    provider = Provider.find_by_adapter_class('Ec2Adapter',
      :include => [ :vm_os_types, :vm_price_types, :vm_prices, :regions, :instance_vm_types  ])

vm_os_types = [
[OsType.find_by_api_name('linux').id, 'linux-base', 'Linux/UNIX'],
[OsType.find_by_api_name('windows').id, 'windows-base', 'Windows']
]
    vm_os_types.each do |vot|
      if provider.vm_os_types.find_by_api_name(vot[1]).nil?
        provider.vm_os_types.create({
          :os_type_id => vot[0],
          :api_name => vot[1],
          :name => vot[2],
        })
      end
    end

vm_price_types = [
['on-demand','On-Demand Instances'],
['reserved','Reserved Instances'],
['spot','Spot Instances']
]
    vm_price_types.each do |vpt|
      if provider.vm_price_types.find_by_api_name(vpt[0]).nil?
        provider.vm_price_types.create({
          :api_name => vpt[0],
          :name => vpt[1]
        })
      end
    end

vpt_id = VmPriceType.find_by_provider_id_and_api_name(provider.id,'on-demand').id
region_id = Region.find_by_provider_id_and_api_name(provider.id,'us-east-1').id
vm_os_type_id = VmOsType.find_by_provider_id_and_api_name(provider.id,'linux-base').id

vm_prices = [
[InstanceVmType.find_by_provider_id_and_api_name(provider.id,'t1.micro').id,'0.020'],
[InstanceVmType.find_by_provider_id_and_api_name(provider.id,'m1.small').id,'0.085'],
[InstanceVmType.find_by_provider_id_and_api_name(provider.id,'m1.large').id,'0.340'],
[InstanceVmType.find_by_provider_id_and_api_name(provider.id,'m1.xlarge').id,'0.680'],
[InstanceVmType.find_by_provider_id_and_api_name(provider.id,'m2.xlarge').id,'0.500'],
[InstanceVmType.find_by_provider_id_and_api_name(provider.id,'m2.2xlarge').id,'1.000'],
[InstanceVmType.find_by_provider_id_and_api_name(provider.id,'m2.4xlarge').id,'2.000'],
[InstanceVmType.find_by_provider_id_and_api_name(provider.id,'c1.medium').id,'0.170'],
[InstanceVmType.find_by_provider_id_and_api_name(provider.id,'c1.xlarge').id,'0.680'],
[InstanceVmType.find_by_provider_id_and_api_name(provider.id,'cc1.4xlarge').id,'1.600'],
[InstanceVmType.find_by_provider_id_and_api_name(provider.id,'cg1.4xlarge').id,'2.100']
]
    vm_prices.each do |vp|
      if VmPrice.find_by_provider_id_and_vm_price_type_id_and_region_id_and_vm_os_type_id_and_instance_vm_type_id(provider.id,vpt_id,region_id,vm_os_type_id, vp[0]).nil?
        provider.vm_prices.create({
          :vm_price_type_id => vpt_id,
          :region_id => region_id,
          :instance_vm_type_id => vp[0],
          :vm_os_type_id => vm_os_type_id,
          :price_unit => '$',
          :price_period => 'hour',
          :price => vp[1]
        })
      end
    end
  end

  def self.down
  end
end
