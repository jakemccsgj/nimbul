require 'AWS/AS'
require 'AWS/ELB'
require 'base64'
require 'pp'

class ElbAdapter
  def self.get_elb(account)
    return if account.nil?
    return if account.aws_access_key.blank? or account.aws_secret_key.blank?
    keys = [ account.aws_access_key, account.aws_secret_key ]
    AWS::ELB.new(*keys)
  end

  def self.refresh_account(account, resources = nil)
    if get_elb(account).nil?
      Rails.logger.error "Account [#{account.id} - #{account.name}] failed to refresh - unable to load AWS::ELB object using account credentials."
      return
    end
      
    if resources.nil? or resources == 'load_balancers'
      begin
        refresh_load_balancers(account)
      rescue Exception => e
        Rails.logger.error "#{e.class.name}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
      end
    end
  end

  def self.refresh_load_balancers(account)
    elb = get_elb(account)
    # refresh all load balancers
    options = {}
    parsers = elb.describe_load_balancers(options)

    account_load_balancers = account.load_balancers
    account_instances = account.instances

    load_balancers = []
    parsers.each do |parser|
      balancer = parse_load_balancer_info(account, parser, account_load_balancers, account_instances)
      balancer.save
      load_balancers << balancer
    end

    account.load_balancers = load_balancers
  end

  def self.refresh_load_balancer(account, load_balancer_name)
    elb = get_elb(account)
    # refresh one load balancer
    options = {
      :load_balancer_names => [ load_balancer_name ]
    }
    parsers = elb.describe_load_balancers(options)
    
    account_load_balancers = account.load_balancers
    account_instances = account.instances

    load_balancers = []
    parsers.each do |parser|
      balancer = parse_load_balancer_info(account, parser, account_load_balancers, account_instances)
      load_balancers << balancer
    end

    return load_balancers[0]
  end

  def self.create_load_balancer(load_balancer)
    account = load_balancer.provider_account
    elb = get_elb(account)

    options = load_balancer_to_options(load_balancer)

    # provision the load balancer and get its DNS name back
    begin
      # register load balancer itself with listeners and availability zones
      result = elb.create_load_balancer(options)
      load_balancer.d_n_s_name = (result.to_hash)['d_n_s_name']

      # configure health checks
      if options[:health_check]
        result = elb.create_health_check(options)
      end
      
      # register instances with the load balancer
      unless options[:instances].empty?
        result = elb.create_elb_instance(options)
      end
    rescue Exception => e
      msg = "Failed to create load balancer '#{load_balancer.name}': #{e.message}"
      Rails.logger.error msg+"\n\t#{e.backtrace.join("\n\t")}"
      load_balancer.errors.add_to_base "#{msg}"
      return false
    end

    return true
  end

  def self.update_load_balancer(load_balancer)
    account = load_balancer.provider_account

    cloud_load_balancer = refresh_load_balancer(account, load_balancer.load_balancer_name)

    elb = get_elb(account)
    begin
      result = elb.create_load_balancer(options)
      load_balancer.d_n_s_name = (result.to_hash)['d_n_s_name']
      unless load_balancer.instances.empty?
        options = {
          :load_balancer_name => load_balancer.load_balancer_name,
          :instances => load_balancer.instances.collect{|i| { :instance_id => i.instance_id}}
        }
        result = elb.create_elb_instance(options)
      end
    rescue Exception => e
      msg = "Failed to create load balancer '#{load_balancer.name}': #{e.message}"
      Rails.logger.error msg+"\n\t#{e.backtrace.join("\n\t")}"
      load_balancer.errors.add_to_base "#{msg}"
      return false
    end

    return true
  end

  def self.delete_load_balancer(load_balancer)
    elb = get_elb(load_balancer.provider_account)
    
    options = {
      :load_balancer_name => load_balancer.load_balancer_name
    }
    
    begin
      elb.delete_load_balancer(options)
    rescue Exception => e
      msg = "Failed to delete load balancer '#{load_balancer.name}': #{e.message}"
      Rails.logger.error msg+"\n\t#{e.backtrace.join("\n\t")}"
      load_balancer.errors.add_to_base "#{msg}"
      return false
    end

    return true
  end

  def self.parse_load_balancer_info(account, parser, account_load_balancers, account_instances)
    load_balancer = account_load_balancers.detect{ |s| s.load_balancer_name == parser.load_balancer_name }

    # convert parser object into hash
    attributes = parser.to_hash

    zone_names = attributes['availability_zones'] || []
    attributes.delete('availability_zones')

    health_check_parser = attributes['health_check']
    attributes.delete('health_check')

    listener_parsers = attributes['listener_descriptions'] || []
    attributes.delete('listener_descriptions')

    instance_parsers = attributes['instances']
    attributes.delete('instances')

    # TODO add support for policies
    policy_parser = attributes['policies']
    attributes.delete('policies')

    if load_balancer.nil?
      load_balancer = account.load_balancers.build(attributes)
    else
      load_balancer.attributes = attributes
    end

    # get zones
    load_balancer.zones = account.zones.collect{|z| z if zone_names.include?(z.name)}.compact

    # get health check
    health_checks = []
    unless health_check_parser.nil?
      h = health_check_parser.to_hash
      h = HealthCheck.parse(h)
      check = HealthCheck.find_by_load_balancer_id_and_target_protocol_and_target_port(load_balancer.id, h[:target_protocol], h[:target_port])
      check = load_balancer.health_checks.build(h) if check.nil?
      health_checks << check
    end
    load_balancer.health_checks = health_checks

    # get listeners
    listeners = []
    listener_parsers.each do |l|
      l = l.to_hash
      l = l['listener'].to_hash
      # elb's listeners don't have to have instance_protocol specified if it's the same as its elb's protocol
      l['instance_protocol'] ||= l['protocol']
      listener = nil
      listener = LoadBalancerListener.find_by_load_balancer_id_and_load_balancer_port_and_instance_port_and_protocol(load_balancer.id, l['load_balancer_port'].to_i, l['instance_port'].to_i, l['protocol']) unless load_balancer.id.nil?
      listener = load_balancer.load_balancer_listeners.build(l) if listener.nil?
      listeners << listener
    end
    load_balancer.load_balancer_listeners = listeners

    # get instance states
    unless instance_parsers.empty?
      elb = get_elb(account)
      load_balancer_instance_states = load_balancer.load_balancer_instance_states
      
      options ={
        :load_balancer_name => load_balancer.load_balancer_name
      }
      cloud_instance_states = elb.describe_instance_states(options) || []

      instance_states = []
      cloud_instance_states.each do |cis|
        instance = account_instances.detect{|i| i.instance_id == cis.instance_id}
        unless instance
          instance = account.instances.create({:instance_id => cis.instance_id})
        end
        instance_state = load_balancer_instance_states.detect{|i| i.instance_id == instance.id}
        # existing instance state record
        if instance_state
          instance_state.update_attributes({
              :state => cis.state,
              :reason_code => cis.reason_code,
              :description => cis.description
            }
          )
          # new instance state record
        else
          instance_state = load_balancer.instance_states.create({
              :instance_id => instance.id,
              :state => cis.state,
              :reason_code => cis.reason_code,
              :description => cis.description
            }
          )
        end
        instance_states << instance_state
      end

      load_balancer.load_balancer_instance_states = instance_states
    end

    return load_balancer
  end

  private

  def self.load_balancer_to_options(load_balancer)
    options = {}
    load_balancer.attributes.each{|a,value| options[a.to_sym] = value}

    # prepare listeners
    listeners = []
    load_balancer.load_balancer_listeners.each do |l|
      listener = {}
      l.attributes.each{|a,value| listener[a.to_sym] = value}
      listeners << listener
    end
    options[:listeners] = listeners

    # prepare listeners
    health_checks = []
    load_balancer.health_checks.each do |h|
      health_check = {}
      h.attributes.each{|a,value| health_check[a.to_sym] = value}
      health_check[:target] = h.target
      health_checks << health_check
    end
    options[:health_checks] = health_checks
    options[:health_check] = health_checks[0]

    # prepare availability zones
    options[:availability_zones] = load_balancer.zones.collect{|i| i.name}

    # prepare instances
    options[:instances] = load_balancer.instances.collect{|i| { :instance_id => i.instance_id}}

    return options
  end

  #####################

  def self.create_load_balancer_listener(l)
    elb = get_elb(l.provider_account)
    options = Hash.new
    l.attributes.each{ |a,value| options[a.to_sym] = value }
    options[:load_balancer_name] = l.load_balancer.load_balancer_name

    # TODO remove
    debugger
        
    return elb.create_load_balancer_listener(options)
  end

  def self.delete_load_balancer_listener(c)
    elb = get_elb(c.provider_account)
    begin
      elb.delete_load_balancer_listener({ :load_balancer_listener_name => c.load_balancer_listener_name})
      return true
    rescue
      c.status_message = "#{$!}"
    end
    return false
  end
    
  def self.refresh_load_balancer_listeners(account)
    elb = get_elb(account)
    parsers = elb.describe_load_balancer_listeners({})

    parsers.each do |parser|
      config = parse_load_balancer_listener_info(account, parser)
      config.state = :active
      config.save
    end
    account.load_balancer_listeners.each do |i|
      i.state = :disabled unless parsers.detect{ |p| p.load_balancer_listener_name == i.load_balancer_listener_name }
    end
    account.save_load_balancer_listeners
  end

  def self.create_health_check(g)
    elb = get_elb(g.provider_account)
    options = Hash.new
    g.attributes.each{ |a, value| options[a.to_sym] = value }
    options[:health_check_name] = g.name
    options[:load_balancer_listener_name] = g.load_balancer_listener.load_balancer_listener_name
    options[:availability_zones] = g.zones.collect{ |z| z.name }
    begin
      elb.create_health_check(options)
      return true
    rescue
      g.status_message = "#{$!}"
    end
    return false
  end

  def self.update_health_check(g)
    elb = get_elb(g.provider_account)
    options = Hash.new
    g.attributes.each{ |a, value| options[a.to_sym] = value }
    options[:health_check_name] = g.name
    options[:load_balancer_listener_name] = g.load_balancer_listener.load_balancer_listener_name
    options[:availability_zones] = g.zones.collect{ |z| z.name }
    elb.update_health_check(options)
    elb.create_desired_capacity(options)
    return true
  end

  def self.disable_health_check(g)
    elb = get_elb(g.provider_account)
    options = {
      :health_check_name => g.name,
      :min_size => 0,
      :max_size => 0,
    }
    elb.update_health_check(options)
    return true
  end
    
  def self.delete_health_check(g)
    elb = get_elb(g.provider_account)
    elb.delete_health_check({ :health_check_name => g.name })
    return true
  end
    
  def self.refresh_health_checks(account)
    elb = get_elb(account)
    parsers = elb.describe_health_checks({})

    parsers.each do |parser|
      group = parse_health_check_info(account, parser)
      group.save
      refresh_auto_scaling_triggers(account, group) if group.active?
    end

    account.health_checks.each do |i|
      i.state = :disabled unless parsers.detect{ |p| p.health_check_name == i.name }
    end
    account.save_health_checks
  end

  def self.create_update_auto_scaling_trigger(ast)
    elb = get_elb(ast.health_check.provider_account)
    options = Hash.new
    ast.attributes.each{ |a,value| options[a.to_sym] = value }
        
    options[:trigger_name] = ast.name
    options[:health_check_name] = ast.health_check.name
    options[:dimensions] = [
      {
        :name => 'AutoScalingGroupName',
        :value => ast.health_check.name,
      }
    ]
    options[:namespace] = 'AWS/EC2'
        
    elb.create_trigger(options)
    return true
  end

  def self.delete_auto_scaling_trigger(ast)
    elb = get_elb(ast.health_check.provider_account)

    options = Hash.new
    options[:trigger_name] = ast.name
    options[:health_check_name] = ast.health_check.name
        
    elb.delete_trigger(options)
    return true
  end

  def self.refresh_auto_scaling_triggers(account, health_check)
    elb = get_elb(account)
    parsers = elb.describe_triggers({:health_check_name => health_check.name})

    parsers.each do |parser|
      trigger = parse_auto_scaling_trigger_info(health_check, parser)
      trigger.save
    end
  end

  private
    
  def self.parse_load_balancer_listener_info(account, parser)
    load_balancer_listener = account.load_balancer_listeners.detect{ |s| s.load_balancer_listener_name == parser.load_balancer_listener_name }

    # convert parser object into hash
    attributes = parser.to_hash

    user_data = attributes['user_data']
    attributes.delete('user_data')

    groups = attributes['security_groups'] || []
    attributes.delete('security_groups')

    volumes = attributes['block_device_mappings'] || []
    attributes.delete('block_device_mappings')
        
    server_image = account.server_images.detect{ |s| s.image_id == attributes['image_id'] }
    attributes['server_image_id'] = server_image.id unless server_image.nil?

    vm_type = account.instance_vm_types.detect{ |z| z.api_name == attributes['instance_type'] }
    attributes[:instance_vm_type_id] = vm_type.id unless vm_type.nil?
    attributes.delete('instance_type')
        
    if load_balancer_listener.nil?
      attributes[:name] = attributes['load_balancer_listener_name']
      load_balancer_listener = account.load_balancer_listeners.build(attributes)
    else
      load_balancer_listener.attributes = attributes
    end
        
    # known issue with AS Launch Configurations - user_data is base64 encoded
    load_balancer_listener.user_data = Base64.decode64(user_data) unless user_data.nil?

    # get security groups
    security_groups = (SecurityGroup.find_all_by_provider_account_id_and_name(account.id, groups))
    load_balancer_listener.security_groups = ( security_groups || [] )

    # get volumes
    volumes.each do |v|
      v_attr = v.to_hash
      mapping = load_balancer_listener.block_device_mappings.detect{ |m| m.virtual_name == v_attr['virtual_name'] }
      if mapping.nil?
        mapping = load_balancer_listener.block_device_mappings.build(v_attr)
      else
        mapping.attributes = v_attr
      end
    end
        
    return load_balancer_listener
  end

  def self.parse_health_check_info(account, parser)
    # convert parser object into hash
    attributes = parser.to_hash

    # name
    attributes[:name] = attributes['health_check_name']
    attributes.delete('health_check_name')

    # launch configuration
    load_balancer_listener_name = attributes['load_balancer_listener_name']
    attributes.delete('load_balancer_listener_name')
    load_balancer_listener = (LaunchConfiguration.find_by_provider_account_id_and_load_balancer_listener_name(account.id, load_balancer_listener_name, :include => :server))
    server = load_balancer_listener.nil? ? nil : load_balancer_listener.server
        
    # zones
    zone_names = attributes['availability_zones'] || []
    attributes.delete('availability_zones')
    zones = account.zones.collect{|z| z if zone_names.include?(z.name)}.compact

    # balancers
    balancer_names = attributes['load_balancer_names'] || []
    attributes.delete('load_balancer_names')
    load_balancers = (LoadBalancer.find_all_by_provider_account_id_and_load_balancer_name(account.id, balancer_names))

    # instances
    instance_parsers = attributes['instances'] || []
    attributes.delete('instances')
    instances = []
    instance_parsers.each do |i|
      # TODO implement better transition here
      h = {}
      i.to_hash.each do |key,value|
        h[key.to_sym] = value
      end
      instance = Ec2Adapter.parse_instance_info(account, {}, h)
      unless server.nil?
        instance.server_id = server.id
        instance.server_name = server.name
      end
      instance.save
      instances << instance
    end
        
    health_check = account.health_checks.detect{ |s| s.name == parser.health_check_name }
    if health_check.nil?
      health_check = account.health_checks.build(attributes)
      health_check.state = :active
    elsif health_check.disabling?
      # if the group exists and is in disabling state - check to see if there are any instances
      # if there are none - remove the group
      health_check.remove! if (instances.nil? or instances.size == 0)
    else
      health_check.attributes = attributes
      health_check.state = :active
    end

    health_check.load_balancer_listener_id = load_balancer_listener.id
    health_check.zones = ( zones || [] )
    health_check.load_balancers = ( load_balancers || [] )
    health_check.instances = ( instances || [] )
        
    return health_check
  end

  def self.parse_auto_scaling_trigger_info(health_check, parser)
    # convert parser object into hash
    attributes = parser.to_hash
        
    # TODO - process dimensions
    attributes.delete('dimensions')

    # trigger name
    attributes[:name] = attributes['trigger_name']
    attributes.delete('trigger_name')

    # delete extra attribute
    attributes.delete('health_check_name')

    auto_scaling_trigger = health_check.auto_scaling_triggers.detect{ |s| s.name == parser.trigger_name }
    if auto_scaling_trigger.nil?
      auto_scaling_trigger = health_check.auto_scaling_triggers.build(attributes)
    else
      auto_scaling_trigger.attributes = attributes
    end

    return auto_scaling_trigger
  end
end
