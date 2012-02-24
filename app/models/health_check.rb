class HealthCheck < ActiveRecord::Base
    belongs_to :load_balancer
    # auditing
    has_many :audit_logs, :as => :auditable, :dependent => :nullify

    validates_presence_of :target_protocol, :target_port, :timeout, :interval, :unhealthy_threshold, :healthy_threshold
    validates_presence_of :target_path,
        :if => :support_target_path?,
        :message => "must specify Ping Path when choosing #{ELB_HEALTH_CHECK_PROTOCOL_WITH_PATH_NAMES.join(' or ')}"
    validates_length_of :target_path,
        :if => :support_target_path?,
        :within => 1..1024
    validates_inclusion_of :target_protocol,
        :in => ELB_HEALTH_CHECK_PROTOCOL_NAMES,
        :allow_nil => false,
        :message => "must be one of #{ELB_HEALTH_CHECK_PROTOCOL_NAMES.join(', ')}"
    validates_numericality_of :target_port,
        :integer_only => true,
        :allow_nil => false,
        :greater_than_or_equal_to => 1,
        :less_than_or_equal_to => 65535,
        :message => 'the range of valid ports is 1 through 65535'
    validates_numericality_of :timeout,
        :integer_only => true,
        :allow_nil => false,
        :greater_than_or_equal_to => 5,
        :message => 'must be a valid integer greater or equal to 5 and less than Interval value'
    validates_numericality_of :interval,
        :integer_only => true,
        :allow_nil => false,
        :greater_than_or_equal_to => 5,
        :message => 'must be a valid integer greater than Timeout value'
    validate :valid_timeout?
    validates_inclusion_of :unhealthy_threshold, :healthy_threshold,
        :in => ELB_THRESHOLD_VALUES,
        :allow_nil => false,
        :message => "must be one of #{ELB_THRESHOLD_VALUES.join(', ')}"

    before_save :parse_values_from_ui

    include TrackChanges # must follow any before filters

    def support_target_path?
        ELB_HEALTH_CHECK_PROTOCOL_WITH_PATH_NAMES.include?(target_protocol)
    end

    def valid_timeout?
        unless self.timeout < self.interval
            self.errors.add(:timeout, "must be less than the Health Check Interval value")
        end
    end

    def parse_values_from_ui
        unless support_target_path?
            self.target_path = nil
        end
    end

    def target
        t = "#{target_protocol}:#{target_port}"
        t += "#{target_path}" unless target_path.blank?
        return t
    end

    attr_accessor :should_destroy
    def should_destroy?
        should_destroy.to_i == 1
    end

    def self.parse(h)
        target = h['target']
        h.delete('target')
        m = /(.*):(\d+)(.*)/.match(target)
        h[:target_protocol] = m.captures[0]
        h[:target_port] = m.captures[1]
        h[:target_path] = m.captures[2] unless m.captures[2].blank?
        return h
    end
end
