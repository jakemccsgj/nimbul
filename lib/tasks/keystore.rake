namespace :keystore do
  cmd = 'ruby lib/transient_key_store_controller.rb'
  desc "Start Keystore"
  task :start => :environment do
    puts `#{cmd} start`
  end

  desc "Stop Keystore"
  task :stop => :environment do
    puts `#{cmd} stop`
  end

  desc "Keystore Status"
  task :status => :environment do
    puts `#{cmd} status`
  end
end
