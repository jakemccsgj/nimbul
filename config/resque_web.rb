require 'resque'
require 'yaml'
Resque.redis = '127.0.0.1:6379'

require 'resque_scheduler'
require 'resque_scheduler/server'

Resque.schedule = YAML.load_file(File.join(File.dirname(__FILE__), 'resque_schedule.yml'))
