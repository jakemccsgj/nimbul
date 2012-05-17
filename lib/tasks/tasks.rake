namespace :tasks_daemon do
  desc "Run the tasks_daemon"
  task :run => :environment do
    Task.perform
  end
end
