#!/usr/bin/env ruby

LOOP_SLEEP_TIME = 300

require 'rubygems'

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"
load File.join(RAILS_ROOT, 'lib', 'detached_workers.rb')

DetachedWorkers.post_fork { ActiveRecord::Base.connection.reconnect! }
DetachedWorkers.adjust_worker_priority 15

$running = true
$manager = DetachedWorkers::Manager.instance

def shutdown
  $running = false
  $manager.shutdown!
end

Signal.trap("TERM") { shutdown }
Signal.trap("INT")  { shutdown }


while($running) do
  Rails.logger.info File.basename(__FILE__, '.rb') + " daemon is still running at #{Time.now}.\n"

  ProviderAccount.all.each do |account|
    unless Ec2Adapter.get_ec2(account).nil?
      $manager.add_task { account.refresh }
    end
  end

  # wait for all tasks to finish
  $manager.complete_tasks

  sleep LOOP_SLEEP_TIME
end
