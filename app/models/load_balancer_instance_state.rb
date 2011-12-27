class LoadBalancerInstanceState < BaseModel
  belongs_to :load_balancer
  belongs_to :instance

  attr_accessor :should_destroy
  def should_destroy?
    should_destroy.to_i == 1
  end
end
