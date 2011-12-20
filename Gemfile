source :rubygems

gem 'aws'
gem 'daemons'
gem 'drb'
gem 'rails', '~> 2.3.0'
gem 'Ruby-MemCache', :require => 'memcache'
gem 'ruby-openid'
gem 'facter'
gem 'aasm'
gem 'aws-s3', :require => 'aws/s3'
gem 'carrot'
gem 'chronic'
gem 'emissary'
gem 'fastthread'
gem 'mysql', '~> 2.8.1'
gem 'net-sftp', :require => 'net/sftp'
gem 'net-ssh', :require => 'net/ssh'
gem 'rufus-scheduler'
gem 'work_queue', '~> 1.0.0'
git 'https://github.com/nimbul/cloudmaster.git' do
  gem 'cloudmaster'
end
git 'https://github.com/justinfrench/formtastic.git', :branch => '1.2-stable' do
  gem 'formtastic', :branch => '1.2-stable'
end
git 'https://github.com/Velir/open_id_authentication.git', :tag => 'v1.0.0' do
  gem 'open_id_authentication'
end
group :development do
end

group :test do
  gem 'rspec'
  gem 'autotest'
  gem 'ZenTest'
  gem 'cucumber'
end

group :production do
end
