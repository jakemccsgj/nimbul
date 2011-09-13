class LoadBalancerInstanceState < BaseModel
    belongs_to :load_balancer
    belongs_to :instance

    validates_presence_of :load_balancer_id, :instance_id

    attr_accessor :should_destroy
    def should_destroy?
        should_destroy.to_i == 1
    end
end
