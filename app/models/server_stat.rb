class ServerStat < ActiveRecord::Base
    attr_accessor :zone
    def count
        instance_count
    end
end
