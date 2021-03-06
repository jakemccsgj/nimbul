class Publisher < BaseModel
  include Loggable
  include Resque::Plugins::UniqueJob
  @loner_ttl = 60

  belongs_to :provider_account
  has_many :publisher_parameters, :dependent => :destroy

  validates_associated :publisher_parameters

  after_update :save_publisher_parameters

  attr_accessor :should_destroy

  default_scope :conditions => ["provider_account_id is not null and provider_account_id not in (select ID from provider_accounts where account_id in (?))", YAML.load(File.read(File.join(RAILS_ROOT, 'config', 'skip_accounts.yml')))]

  def should_destroy?
    should_destroy.to_i == 1
  end

  def save_publisher_parameters
    publisher_parameters.each do |i|
      if i.should_destroy?
        i.destroy
      else
        i.save(false)
      end
    end
  end

  def publisher_parameter_attributes=(publisher_parameter_attributes)
    publisher_parameter_attributes.each do |attributes|
      if attributes[:id].blank?
        publisher_parameters.build(attributes)
      else
        publisher_parameter = publisher_parameters.detect { |c| c.id == attributes[:id].to_i }
        publisher_parameter.attributes = attributes
      end
    end
  end

  def parameter_value(name)
    parameter = publisher_parameters.detect{|p| p.name == name}
    if parameter.nil?
      return nil
    else
      return parameter.value
    end
  end

  # Factory to create instances of subclasses
  def self.factory(class_name = 'Publisher', *params)
    # make sure the class is included first, and don't fail on error loading library
    require File.join(File.dirname(__FILE__), class_name.underscore) rescue false

    begin
      class_name.constantize.new *params
    rescue
      # fallback to operation base
      Publisher.new(params)
    end
  end

  def class_type=(value) self[:type] = value; end
  def class_type() return self[:type]; end

  #methods should be overwritten in subclasses
  def initialize_parameters
    []
  end

  def options(name)
    []
  end

  def is_configuration_good?
    self.state = "failed"
    self.state_text = "is_configuration_good? method is not defined for this Publisher"
    return false
  end

  def publish!
    self.state = "failed"
    self.state_text = "publish! method is not defined for this Publisher"
    return false
  end

  def self.label
    "Publisher"
  end

  class << self
    def queue
      :publishers
    end

    def publish_delayed
      self.all.each { |p|
        Resque.enqueue(p.class, p.id)
      }
    end

    def perform *args
      if !args.empty?
        args.each do |a|
          self[a].publish!
        end
      else
        publish_delayed
      end
    end
  end
end
