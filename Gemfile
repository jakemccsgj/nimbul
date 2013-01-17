source 'http://rubygems.org'
source 'http://gems.rubyforge.org'
source 'http://gemcutter.org'

gem 'activemessaging', :git => 'https://github.com/kookster/activemessaging.git'
gem 'amqp'
gem 'bert'
gem 'emissary'
gem 'daemons'
gem 'aws'
gem 'statemachine'
gem 'rails', '= 2.3.14'
gem 'Ruby-MemCache', :require => 'memcache'
gem 'ruby-openid'
gem 'facter'
gem 'aasm'
gem 'carrot', :git => 'http://github.com/rabbitt/carrot'
gem 'chronic'
gem 'fastthread'
gem 'recaptcha', :require => "recaptcha/rails"
#
## IF you are having an issue with the following error:
#    ... Please install the mysql2 adapter: `gem install activerecord-mysql2-adapter.... Library not loaded: libmysqlclient.18.dylib
#  You are likely on OsX.  That's right, I am a mind reader.  I was able to fix this with information from the following article:
#
#  http://j.mp/uvCiaH
#
#  Which basically amounted to (on my machine):
#
#  sudo install_name_tool -change libmysqlclient.18.dylib /<path to your>/mysql/lib/libmysqlclient.18.dylib /<path to your>/nimbul/vendor/bundle/ruby/1.8/gems/mysql2-0.2.18/lib/mysql2/mysql2.bundle
#
#  You may need to change version numbers to match, and obviously the paths must be changed to match your environment.
#
#gem 'mysql2', "~> 0.2.7"
gem 'mysql'
gem "query_reviewer", :git => "git://github.com/nesquena/query_reviewer.git"
gem 'net-sftp', :require => 'net/sftp'
gem 'net-ssh', :require => 'net/ssh'
gem 'rufus-scheduler'
git 'git://github.com/nimbul/cloudmaster.git', :branch => 'feature/xml_to_nokogiri' do
  gem 'cloudmaster'
end
gem 'nokogiri'
git 'https://github.com/justinfrench/formtastic.git', :branch => '1.2-stable' do
  gem 'formtastic', :branch => '1.2-stable'
end
git 'https://github.com/Velir/open_id_authentication.git', :tag => 'v1.0.0' do
  gem 'open_id_authentication'
end
group :development do
  gem 'wirble'
end

group :test do
  gem 'rspec'
  gem 'autotest'
  gem 'ZenTest'
  gem 'cucumber'
end

group :production do
end

gem 'resque'
gem 'resque-scheduler', :git => 'git://github.com/nimbul/resque-scheduler.git'
gem 'resque-loner', :git => 'https://github.com/jayniz/resque-loner.git'
gem 'grit'
gem 'god'
gem 'log4r'
gem 'attr_encrypted'
gem 'rye'
gem 'god'
