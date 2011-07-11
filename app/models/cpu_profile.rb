class CpuProfile < ActiveRecord::Base
	validates_presence_of :name, :api_name
	validates_uniqueness_of :name, :api_name
end
