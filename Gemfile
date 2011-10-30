source :gemcutter
source :rubyforge

gem 'aws'
gem 'rails', '~> 2.3.0'
gem 'Ruby-MemCache', :require => 'memcache'
gem 'ruby-openid'
#gem 'sysvipc'
gem 'aasm'
gem 'carrot'
gem 'chronic'
gem 'emissary'
gem 'fastthread'
gem 'mysql'
gem 'net-sftp', :require => 'net/sftp'
gem 'net-ssh', :require => 'net/ssh'
gem 'rufus-scheduler'
gem 'work_queue'
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
