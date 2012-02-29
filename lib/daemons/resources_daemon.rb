#!/usr/bin/env ruby

LOOP_SLEEP_TIME = 10

# You might want to change this
ENV["RAILS_ENV"] ||= "production"
ENV['DAEMON_SCRIPTLET'] = 'true'

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
    $running = false
end

while $running do
  Rails.logger.info File.basename(__FILE__).sub('.rb','')+" daemon is still running at #{Time.now}.\n"
  InstanceResource.pending.each do |ir|
    begin
      ir.attach! && Rails.logger.info "Successfully attached #{topic}"
                 || Rails.logger.error "Didn't attach #{topic}: "+ir.errors.collect{ |attr,msg| attr.humanize + ': ' + msg}.join("\n\t")
    rescue Exception => e
      msg = "Failed to attach #{topic}: #{e.message}"
      Rails.logger.error msg+"\n\t#{e.backtrace.join("\n\t")}"
    end
  end
  sleep LOOP_SLEEP_TIME
end
