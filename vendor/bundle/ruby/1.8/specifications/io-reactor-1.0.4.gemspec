# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "io-reactor"
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Granger"]
  s.date = "2008-08-19"
  s.description = "A pure-Ruby implementation of an asynchronous multiplexed IO Reactor which is based on the Reactor design pattern found in _Pattern-Oriented Software Architecture, Volume 2: Patterns for Concurrent and Networked Objects_. It allows a single thread to demultiplex and dispatch events from one or more IO objects to the appropriate handler."
  s.email = "ged@FaerieMUD.org"
  s.homepage = "http://deveiate.org/projects/IO-Reactor/"
  s.rdoc_options = ["-w", "4", "-SHN", "-i", ".", "-m", "README", "-W", "http://deveiate.org/projects/IO-Reactor//browser/trunk/"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "io-reactor"
  s.rubygems_version = "1.8.21"
  s.summary = "Multiplexed IO Reactor class"

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
