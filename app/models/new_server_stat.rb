class NewServerStat < ActiveRecord::Base
    set_table_name 'server_stats'

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

    def self.mycount(date)
      taken_at = "#{date}15".to_date
      month_start = taken_at.beginning_of_month
      month_end = taken_at.end_of_month
      ServerStat.count(
        :all,
        :conditions => ["taken_at between :start and :end", { :start => month_start, :end => month_end}]
      )
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

    def self.fix_all
        ServerStat.fix('201002',6)
        ServerStat.fix('201003',6)
        ServerStat.fix('201004',6)
        ServerStat.fix('201005',6)
        ServerStat.fix('201006',6)
        ServerStat.fix('201007',6)
        ServerStat.fix('201008',6)
        ServerStat.fix('201009',6)
        ServerStat.fix('201010',6)
        ServerStat.fix('201011',6)
        ServerStat.fix('201012',6)
        ServerStat.fix('201101',6)
        ServerStat.fix('201102',6)
        ServerStat.fix('201103',6)
        ServerStat.fix('201104',6)
        ServerStat.fix('201105',6)
        ServerStat.fix('201106',4)
    end
end
