class PopulateRegionNames < ActiveRecord::Migration
  def self.up
    Region.all.each do |r|
      r.update_attribute(:name, r.api_name) if r.name.empty?
    end
  end

  def self.down
  end
end
