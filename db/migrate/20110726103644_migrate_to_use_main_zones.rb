class MigrateToUseMainZones < ActiveRecord::Migration
  class Zone < ActiveRecord::Base
    has_many :cloud_resources
    has_many :instances
    has_many :reserved_instances
    has_many :resource_bundles
    has_many :servers
  end

  def self.up
    Region.all.each do |r|
      Zone.update_all({ :region_id => r.id }, ['name LIKE :region_name', { :region_name => r.api_name+'%' }])
    end
    zs = Zone.find_by_sql('select distinct(name) from zones order by name')
    zs.each do |i|
      z = Zone.find_by_name(i.name, :order => :id)
      o_zones = Zone.find_all_by_name(
        z.name,
        :order => :id
      ).select{ |j| j.id != z.id }
      o_zones.each do |oz|
        CloudResource.update_all({ :zone_id => z.id }, { :zone_id => oz.id })
        Instance.update_all({ :zone_id => z.id }, { :zone_id => oz.id })
        ReservedInstance.update_all({ :zone_id => z.id }, { :zone_id => oz.id })
        ResourceBundle.update_all({ :zone_id => z.id }, { :zone_id => oz.id })
        Server.update_all({ :zone_id => z.id }, { :zone_id => oz.id })
        oz.destroy
      end
    end
  end

  def self.down
  end
end
