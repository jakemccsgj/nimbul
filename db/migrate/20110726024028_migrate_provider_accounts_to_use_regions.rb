class MigrateProviderAccountsToUseRegions < ActiveRecord::Migration
  def self.up
    provider = Provider.find_by_adapter_class('Ec2Adapter', :include => [:regions, { :provider_accounts => :regions }])
    region = provider.regions.detect{|r| r.api_name == 'us-east-1'}
    provider.provider_accounts.each{ |p| p.regions << region unless p.regions.include?(region)}
  end

  def self.down
  end
end
