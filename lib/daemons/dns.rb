#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"
ENV['DAEMON_SCRIPTLET'] = 'true'

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do
  $running = false
end

while($running) do
    # process any dns acquire/release requests
    DnsRequest.process
    sleep 10
end
