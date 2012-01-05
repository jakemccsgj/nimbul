class Parent::StatsController < ApplicationController
  parent_resources :account_group, :app, :provider_account, :cluster, :server
#  before_filter :login_required
#  require_role  :admin

  def prepare
    @parent = parent

    @reserved_instances = []
    reserved_select = []
    reserved_select << 'select z.id as zone_id, instance_vm_type_id, sum(count) as count, usage_price from reserved_instances i, zones z where i.zone_id = z.id and'
    reserved_select << ''
    reserved_select << 'group by zone_id, instance_vm_type_id, usage_price'
    reserved_select << 'order by z.name, usage_price'
    reserved_condition = {}

    @running_instances = []
    running_select = []
    running_select << 'select z.id as zone_id, instance_vm_type_id, count(i.id) as count from instances i, zones z where i.zone_id = z.id and'
    running_select << ''
    running_select << 'group by zone_id, instance_vm_type_id'
    running_select << 'order by z.name'
    running_condition = {}

    #
    # reserved instances are useful on account group level only
    # TODO refactor to a more elegant solution
    #
    if @parent.is_a? AccountGroup
      running_select[1] = "i.provider_account_id in (select id from provider_accounts where account_group_id=:account_group_id)" 
      running_condition = { :account_group_id => @parent.id }
      reserved_select[1] = running_select[1]
      reserved_condition = running_condition
      @reserved_instances = ReservedInstance.find_by_sql([reserved_select.join(' '), reserved_condition])
    elsif @parent.is_a? App 
      running_select[1] = "i.server_id in (select id from servers where cluster_id in (#{@parent.cluster_ids.join(',')}))"
      running_condition = {}
    elsif @parent.is_a? ProviderAccount
      running_select[1] = "i.provider_account_id=:provider_account_id"
      running_condition = { :provider_account_id => @parent.id }
    elsif @parent.is_a? Cluster
      if @parent.server_ids.empty?
        running_select[1] = "i.server_id=0"
      else
        running_select[1] = "i.server_id in (#{@parent.server_ids.join(',')})"
      end
      running_condition = {}
    elsif @parent.is_a? Server
      running_select[1] = "i.server_id=:server_id"
      running_condition = { :server_id => @parent.id  }
    end

    #
    # running instances are useful for all parents
    #
    @running_instances = ReservedInstance.find_by_sql([running_select.join(' '), running_condition])

    #
    # get server stats
    #
    stats_condition = ['',{}]
    if @parent.is_a? Cluster
      stats_condition = "cluster_id=#{@parent.id}"
    elsif @parent.is_a? Server
      stats_condition = "server_id=#{@parent.id}"
    elsif @parent.cluster_ids.length > 0
      stats_condition = "cluster_id in (#{@parent.cluster_ids.join(',')})"
    end

    @latest_taken_at = nil
    @start_date = nil
    @end_date = nil

    if params[:year].nil?
      @start_date = Date.current.beginning_of_month
      @end_date = Date.current.end_of_month
    elsif params[:month].nil?
      @start_date = "#{params[:year]}0115".to_date.beginning_of_month
      @end_date = "#{params[:year]}1215".to_date.end_of_month
    elsif params[:toyear].nil?
      @start_date = "#{params[:year]}#{params[:month]}15".to_date.beginning_of_month
      @end_date = "#{params[:year]}#{params[:month]}15".to_date.end_of_month
    elsif params[:tomonth].nil?
      @start_date = "#{params[:year]}#{params[:month]}15".to_date.beginning_of_month 
      @end_date = "#{params[:toyear]}0115".to_date.beginning_of_month
    else
      @start_date = "#{params[:year]}#{params[:month]}15".to_date.beginning_of_month
      @end_date = "#{params[:toyear]}#{params[:tomonth]}15".to_date.end_of_month
    end

    conditions = [
      "#{stats_condition} and taken_at between :start_date and :end_date",
      { :start_date => @start_date, :end_date => @end_date}
    ]

    @bar_start_date = ServerStat.minimum(:taken_at)
    @bar_end_date = ServerStat.maximum(:taken_at)

    @latest_taken_at = ServerStat.maximum(
      :taken_at,
      :conditions => conditions
    )

    if @latest_taken_at.nil?
      @server_stats = []
    else
      @latest_taken_at = @latest_taken_at.to_date
      if @latest_taken_at >= @end_date
          @multiplier = 1
      else
          days_passed = (@latest_taken_at - @start_date).to_f
          days_left = (@end_date - @latest_taken_at).to_f
          if days_passed == 0
              @multiplier = 30
          else
              @multiplier = (days_passed + days_left) / days_passed
          end
      end

      order = ServerStat.sort_fields[0]
      if !params[:sort].nil? and ServerStat.sort_fields.include?(params[:sort].sub(/_reverse/,''))
          order = params[:sort].sub(/_reverse/,' DESC')
      end

      @server_stats = ServerStat.find(
        :all,
        :select => 'cluster_id, server_id, instance_vm_type_id, sum(instance_count) as instance_count',
        :conditions => conditions,
        :group => 'cluster_id, server_id, instance_vm_type_id',
        :include => [ { :instance_vm_type => :vm_prices }, :cluster, :server],
        :order => order
      )
    end

    cluster_id = nil
    first_ss = nil
    @total = BigDecimal('0.0')
    @projection = BigDecimal('0.0')
    @server_stats.each do |ss|
       if cluster_id.nil? or cluster_id != ss.cluster_id
           cluster_id = ss.cluster_id
           first_ss = ss
           first_ss.cluster_cost = BigDecimal.new('0.00')
           first_ss.server_count = 0
       end 
       first_ss.server_count += 1
       first_ss.cluster_cost += ss.server_cost unless ss.server_cost.nil?
       @total += ss.server_cost unless ss.server_cost.nil?
    end
    @projection = @total*@multiplier unless @multiplier.nil?
  end

  def index
    prepare

    respond_to do |format|
      format.html
      format.xml  { render :xml => @server_stats }
      format.js { render :partial => 'stats/list', :layout => false }
    end
  end

  def total
    prepare

    respond_to do |format|
      format.html
      format.xml  { render :xml => @server_stats }
      format.js
    end
  end

end
