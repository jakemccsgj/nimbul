class LoadBalancer < BaseModel
  belongs_to :provider_account
  has_and_belongs_to_many :zones, :order => :name, :uniq => true

  has_many :load_balancer_listeners, :dependent => :destroy
  has_many :health_checks, :dependent => :destroy

  has_many :load_balancer_instance_states, :dependent => :destroy
  has_many :instances, :through => :load_balancer_instance_states,
    :uniq => true

  validates_presence_of :load_balancer_name
  validates_uniqueness_of :load_balancer_name,
    :scope => [ :provider_account_id ]
  validates_presence_of :load_balancer_listeners,
    :message => 'you must specify at least one listener.'
  validates_presence_of :health_checks,
    :message => 'you must specify at least one health check.'
  validates_presence_of :zones,
    :message => 'you must specify at least one availability zone.'
  
  accepts_nested_attributes_for :load_balancer_listeners,
    :reject_if => proc { |a| a['load_balancer_port'].blank? and a['instance_port'].blank? },
    :allow_destroy => true
  accepts_nested_attributes_for :health_checks,
    :allow_destroy => true

  include TrackChanges # must follow any before filters
  
  attr_accessor :new_cloud_record
  def new_cloud_record?
    (new_cloud_record.nil? ? true : new_cloud_record)
  end

  def name
    self.load_balancer_name
  end

  def can_use_more_of?(load_balancer_resource_type)
    case load_balancer_resource_type
    when 'LoadBalancerListener':
        return true
    when 'LoadBalancerInstanceState':
        return true
    when 'HealthCheck':
        return (health_checks.count == 0)
    else
      return false
    end
  end

  def can_loose_some_of?(load_balancer_resource_type)
    case load_balancer_resource_type
    when 'HealthCheck':
        return (health_checks.count > 1)
    else
      return true
    end
  end

  # sort, search and paginate parameters
  def self.per_page
    10
  end

  def self.sort_fields
    %w(load_balancer_name d_n_s_name)
  end

  def self.search_fields
    %w(load_balancer_name d_n_s_name)
  end

  def self.filter_fields
    %w(load_balancer_name d_n_s_name)
  end

  def self.search_by_provider_account(provider_account, search, options={})
    extra_joins = options[:joins]
    extra_conditions = options[:conditions]

    joins = extra_joins
    conditions = [ 'provider_account_id = ?', (provider_account.is_a?(ProviderAccount) ? provider_account.id : provider_account) ]
    unless extra_conditions.blank?
      extra_conditions = [ extra_conditions ] if not extra_conditions.is_a? Array
      conditions[0] << ' AND ' + extra_conditions[0];
      conditions << extra_conditions[1..-1]
    end

    options[:joins] = joins
    options[:conditions] = conditions

    search(search, options)
  end
end
