class LoadBalancerListener < BaseModel
  belongs_to :load_balancer
  validates_presence_of :protocol, :load_balancer_port, :instance_protocol, :instance_port
  validates_numericality_of :load_balancer_port, :instance_port,
    :only_integer => true,
    :greater_than_or_equal_to => 0,
    :less_than_or_equal_to => 65535
  validates_uniqueness_of :load_balancer_port,
    :scope => [ :load_balancer_id ],
    :message => 'Cannot use duplicate load balancer ports.'

  def description
    "#{load_balancer_port} (#{protocol}) forwarding to #{instance_port} (#{instance_protocol})"
  end

  attr_accessor :should_destroy
  def should_destroy?
    should_destroy.to_i == 1
  end
end
