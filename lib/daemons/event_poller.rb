#!/usr/bin/env ruby
require File.dirname(__FILE__) + "/../../config/environment"

Rails.logger.auto_flushing = true

# You might want to change this
ENV["RAILS_ENV"] ||= "production"
ENV['DAEMON_SCRIPTLET'] = 'true'

$running = true
Signal.trap("TERM") do 
  $running = false
end

ActiveMessaging::start
