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
  
  accepts_nested_attributes_for :load_balancer_listeners,
    :reject_if => proc { |a| a['load_balancer_port'].blank? and a['instance_port'].blank? },
    :allow_destroy => true
  accepts_nested_attributes_for :health_checks,
    :allow_destroy => true

  include TrackChanges # must follow any before filters

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
end
