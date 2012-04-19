class InstanceResource < ActiveRecord::Base
  belongs_to :instance
  belongs_to :cloud_resource, :counter_cache => true
  delegate :provider_account, :to => :instance

  named_scope :pending,
    :conditions => { :state => 'pending' },
    :include    => { :cloud_resource => :instance }

  serialize :params, Hash

  validates_presence_of :cloud_resource_id
  validates_presence_of :mount_type

  before_save :validate_cloud_resource
  attr_accessor :status_message, :cloud_resource_type

  def validate_cloud_resource
    unless self.cloud_resource_id.nil?
      cr = CloudResource.find(self.cloud_resource_id)
      if cr.nil?
        self.errors.add(:cloud_resource_id, "couldn't find cloud resource [#{self.cloud_resource_id}]")
        raise ActiveRecord::Rollback
      elsif !self.can_use_cloud_resource?(cr)
        self.errors.add(:cloud_resource_id, "can't use cloud resource '#{cr.name}' [#{cr.id}]")
        raise ActiveRecord::Rollback
      end
    end
  end

  def class_type=(value) self[:type] = value; end
  def class_type() return self[:type]; end
  def short_type
    self[:type].underscore.gsub('instance_','')
  end
  def short_types
    self[:type].tableize.gsub('instance_','')
  end

  def can_use_cloud_resource?(cloud_resource)
    self.instance.can_use_cloud_resource?(cloud_resource)
  end

  def attach!
    unless instance.running?
      self.errors.add(:instance_id, "is not in the running state")
      return false
    end

    begin
      RAILS_DEFAULT_LOGGER.info('Attaching cloud resource id %s to instance id %s' % [cloud_resource.id, instance.id])
      cloud_resource.attach! instance, self.force_allocation, self.mount_point
      RAILS_DEFAULT_LOGGER.info('Attaching instance id %s to cloud resource id %s' % [instance.id, cloud_resource.id])
      instance.attach! cloud_resource
      if cloud_resource.errors.empty? and instance.errors.empty?
        self.update_attributes({
          :state => 'attached',
          :state_description => "Attached #{cloud_resource.short_type} '#{cloud_resource.name}' to #{instance.name}",
          :force_allocation => false,
        })
        return true
      else
        # collect errors
        unless cloud_resource.errors.empty?
          self.errors.add(:cloud_resource_id, cloud_resource.errors.collect{ |attr,msg| attr.humanize + ': ' + msg}.join(';'))
        end
        unless instance.errors.empty?
          self.errors.add(:instance_id, instance.errors.collect{ |attr,msg| attr.humanize + ': ' + msg}.join(';'))
        end
        # update attributes
        msg = self.errors.collect{ |attr,msg| attr.humanize + ': ' + msg}.join('\n')
        self.update_attributes({
          :state_description => "Failed to attach #{cloud_resource.short_type} '#{cloud_resource.name}' to #{instance.name}: #{msg}",
        })
        return false
      end
    rescue
      msg = "Failed to attach #{cloud_resource.short_type} '#{cloud_resource.name}' to #{instance.name}: #{$!}"
      self.errors.add(:state, msg)
      self.update_attributes({
        :state_description => msg,
      })
      return false
    end
  end

  def detach!
    cloud_resource = self.cloud_resource
    instance = self.instance
    begin
      instance.detach!(cloud_resource)
      cloud_resource.detach!(self.force_allocation)
      if cloud_resource.errors.empty?  and instance.errors.empty?
        self.update_attributes({
          :state => 'detached',
          :state_description => "Detached #{cloud_resource.short_type} '#{cloud_resource.name}' from #{instance.name}",
          :force_allocation => false,
        })
        return true
      else
        # collect errors
        unless cloud_resource.errors.empty?
          self.errors.add(:cloud_resource_id, cloud_resource.errors.collect{ |attr,msg| attr.humanize + ': ' + msg}.join(';'))
        end
        unless instance.errors.empty?
          self.errors.add(:instance_id, instance.errors.collect{ |attr,msg| attr.humanize + ': ' + msg}.join(';'))
        end
        # update attributes
        msg = self.errors.collect{ |attr,msg| attr.humanize + ': ' + msg}.join('\n')
        self.update_attributes({
          :state_description => "Failed to detach #{cloud_resource.short_type} '#{cloud_resource.name}' from #{instance.name}: #{msg}",
        })
        return false
      end
    rescue
      msg = "Failed to detach #{cloud_resource.short_type} '#{cloud_resource.name}' from #{instance.name}: #{$!}"
      self.errors.add(:state, msg)
      self.update_attributes({
        :state_description => msg,
      })
      return false
    end
  end

  def topic
    "'%s' %s [%s] to %s [%s] through instance resource %s" % [ cloud_resource.name, cloud_resource.cloud_id, cloud_resource.id, instance.instance_id, instance.id, id ]
  end

  class << self
    def process
      self.pending.each do |ir|
        topic = "'#{ir.cloud_resource.name}' #{ir.cloud_resource.cloud_id} [#{ir.cloud_resource.id}]"
        topic += " to #{ir.instance.instance_id} [#{ir.instance.id}]"
        topic += " through instance resource #{ir.id}"
        begin
          if ir.attach!
            Rails.logger.info "Successfully attached #{topic}"
          else
            Rails.logger.error "Didn't attach #{topic}: "+ir.errors.collect{ |attr,msg| attr.humanize + ': ' + msg}.join("\n\t")
          end
        rescue Exception => e
          msg = "Failed to attach #{topic}: #{e.message}"
          Rails.logger.error msg+"\n\t#{e.backtrace.join("\n\t")}"
        end
      end
    end
    alias :perform :process

    def queue; :resources; end
  end
end
