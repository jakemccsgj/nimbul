class LoadBalancer < BaseModel
  belongs_to :provider_account
  has_and_belongs_to_many :zones, :order => :name, :uniq => true

  has_many :load_balancer_listeners, :dependent => :destroy
  has_many :health_checks, :dependent => :destroy

  has_many :load_balancer_instance_states, :dependent => :destroy
  has_many :instances, :through => :load_balancer_instance_states, :uniq => true

  validates_presence_of :load_balancer_name
  validates_uniqueness_of :load_balancer_name, :scope => [ :provider_account_id ]
  validates_presence_of :load_balancer_listeners,
    :message => 'you must specify at least one listener.'
  validates_presence_of :health_checks,
    :message => 'you must specify at least one health check.'
  
  after_update :save_load_balancer_listeners, :save_health_checks, :save_load_balancer_instance_states

  attr_accessor :should_destroy

  def should_destroy?
    should_destroy.to_i == 1
  end

  def save_load_balancer_listeners
    load_balancer_listeners.each do |i|
      if i.should_destroy?
        i.destroy
      else
        i.save(false)
      end
    end
  end

  def save_health_checks
    health_checks.each do |i|
      if i.should_destroy?
        i.destroy
      else
        i.save(false)
      end
    end
  end

  def save_load_balancer_instance_states
    load_balancer_instance_states.each do |i|
      if i.should_destroy?
        i.destroy
      else
        i.save(false)
      end
    end
  end

  def load_balancer_listener_attributes=(load_balancer_listener_attributes)
    load_balancer_listener_attributes.each do |attributes|
      if attributes[:id].blank?
        load_balancer_listeners.build(attributes)
      else
        load_balancer_listener = load_balancer_listeners.detect { |i| i.id == attributes[:id].to_i }
        load_balancer_listener.attributes = attributes
      end
    end
  end

  def health_check_attributes=(health_check_attributes)
    health_check_attributes.each do |attributes|
      if attributes[:id].blank?
        health_checks.build(attributes)
      else
        health_check = health_checks.detect { |i| i.id == attributes[:id].to_i }
        health_check.attributes = attributes
      end
    end
  end

  def load_balancer_instance_state_attributes=(load_balancer_instance_state_attributes)
    load_balancer_instance_state_attributes.each do |attributes|
      if attributes[:id].blank?
        load_balancer_instance_states.build(attributes)
      else
        load_balancer_instance_state = load_balancer_instance_states.detect{ |i| i.id == attributes[:id].to_i }
        load_balancer_instance_state.attributes = attributes
      end
    end
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
end
