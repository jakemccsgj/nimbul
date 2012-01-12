#!/usr/bin/env ruby

LOOP_SLEEP_TIME = 5

require 'rubygems'

# You might want to change this
ENV["RAILS_ENV"] ||= "production"
ENV['DAEMON_SCRIPTLET'] = 'true'

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
    $running = false
end

while($running) do
  resources = InstanceResource.pending
  resources.each do |ir|
    begin
      if ir.cloud_resource.nil?
        RAILS_DEFAULT_LOGGER.error "Error with InstanceResource: #{ir.to_s} - no CloudResource attached!"
        next
      end

      topic = "'#{ir.cloud_resource.name}' #{ir.cloud_resource.cloud_id} [#{ir.cloud_resource.id}]"
      topic += " to #{ir.instance.instance_id} [#{ir.instance.id}]"
      topic += " through instance resource #{ir.id}"
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.error "Caught some barf: #{e}"
    end
    begin
      if ir.attach!
        RAILS_DEFAULT_LOGGER.error "Successfully attached #{topic}"
      else
        RAILS_DEFAULT_LOGGER.error "Didn't attach #{topic}: "+ir.errors.collect{ |attr,msg| attr.humanize + ': ' + msg}.join("\n\t")
      end
    rescue Exception => e
      msg = "Failed to attach #{topic}: #{e.message}"
      RAILS_DEFAULT_LOGGER.error msg+"\n\t#{e.backtrace.join("\n\t")}"
    end
  end

  #$stderr.puts "daemon is still running at #{Time.now}.  Processed #{resources.count.to_s} records\n"
  RAILS_DEFAULT_LOGGER.error File.basename(__FILE__).sub('.rb','')+" daemon is still running at #{Time.now}.  Processed #{resources.count.to_s} records\n"

  Kernel.sleep LOOP_SLEEP_TIME
end
