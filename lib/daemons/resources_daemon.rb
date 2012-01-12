#!/usr/bin/env ruby

LOOP_SLEEP_TIME = 5

# You might want to change this
ENV["RAILS_ENV"] ||= "production"
ENV['DAEMON_SCRIPTLET'] = 'true'

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
    $running = false
end

while($running) do
  Rails.logger.info File.basename(__FILE__).sub('.rb','')+" daemon is still running at #{Time.now}.\n"

  InstanceResource.pending.each do |ir|
    if ir.cloud_resource.nil?
      Rails.logger.warn "Error with InstanceResource: #{ir.to_s} - no CloudResource attached!"
      next
    end

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
  sleep LOOP_SLEEP_TIME
end
