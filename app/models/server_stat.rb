class ServerStat < ActiveRecord::Base
    belongs_to :instance_vm_type, :include => :vm_prices
    belongs_to :cluster
    belongs_to :server

    attr_accessor :zone
    def count
        instance_count
    end

    def instance_type
        return nil if self.instance_vm_type.nil?
        return self.instance_vm_type.api_name
    end

    def vm_prices
        return [] if instance_vm_type.nil?
        return instance_vm_type.vm_prices
    end

    def server_cost
        return nil if vm_prices.empty?
        price = vm_prices[0].price
        (instance_count*price)
    end

    attr_accessor :cluster_cost
    attr_accessor :server_count

    def self.sort_fields
        %w(cluster_id server_id instance_vm_type_id instance_count)
    end

    def self.fix(date,reduce)
      taken_at = "#{date}15".to_date
      month_start = taken_at.beginning_of_month
      month_end = taken_at.end_of_month
      count = 0
      ServerStat.find(
        :all,
        :conditions => ["taken_at between :start and :end", { :start => month_start, :end => taken_at}]
      ).each do |ss|
        ss.destroy unless count.modulo(reduce) == 0 
        count += 1
      end
      count = 0
      ServerStat.find(
        :all,
        :conditions => ["taken_at between :start and :end", { :start => taken_at, :end => month_end}]
      ).each do |ss|
        ss.destroy unless count.modulo(reduce) == 0 
        count += 1
      end
    end
end
