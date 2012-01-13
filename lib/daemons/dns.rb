#!/usr/bin/env ruby

LOOP_SLEEP_TIME = 10

# You might want to change this
ENV["RAILS_ENV"] ||= "production"
ENV['DAEMON_SCRIPTLET'] = 'true'

require File.dirname(__FILE__) + "/../../config/environment"
Rails.logger.auto_flushing = true

$running = true
Signal.trap("TERM") do
  $running = false
end

while $running do
    # process any dns acquire/release requests
    Rails.logger.info("DNS daemon is still running @ #{Time.now}")
    DnsRequest.process_requests
    sleep LOOP_SLEEP_TIME
end
