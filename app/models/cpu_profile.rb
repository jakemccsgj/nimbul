class CpuProfile < ActiveRecord::Base
    has_and_belongs_to_many :instance_vm_types, :uniq => true

    has_many :server_images

    validates_presence_of :name, :api_name
    validates_uniqueness_of :name, :api_name
end
