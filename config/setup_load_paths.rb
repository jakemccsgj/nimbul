if ENV['MY_RUBY_HOME'] && ENV['MY_RUBY_HOME'].include?('rvm')
  begin
    rvm_path     = File.dirname(File.dirname(ENV['MY_RUBY_HOME']))
    rvm_lib_path = File.join(rvm_path, 'lib')
    $LOAD_PATH.unshift rvm_lib_path
    require 'rvm'
    RVM.use_from_path! File.dirname(File.dirname(__FILE__))
  rescue LoadError
    # RVM is unavailable at this point.
    raise "RVM ruby lib is currently unavailable."
  end
end
require 'bundler'
STDERR.puts "HOME = " + ENV['HOME'].inspect
STDERR.puts "gem user home = " + Gem.user_home
STDERR.puts "BUNDLE_PATH = " + ENV['BUNDLE_PATH'].inspect
STDERR.puts "Bundler.requires_sudo? = #{Bundler.requires_sudo?}"
STDERR.puts "Bundler.user_bundle_path = " + Bundler.user_bundle_path.inspect
STDERR.puts "Bundler.install_path = " + Bundler.install_path.inspect
Bundler.setup
