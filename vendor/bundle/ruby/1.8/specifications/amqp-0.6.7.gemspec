# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "amqp"
  s.version = "0.6.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aman Gupta"]
  s.date = "2009-12-29"
  s.description = "An implementation of the AMQP protocol in Ruby/EventMachine for writing clients to the RabbitMQ message broker"
  s.email = "amqp@tmm1.net"
  s.extra_rdoc_files = ["README", "doc/EXAMPLE_01_PINGPONG", "doc/EXAMPLE_02_CLOCK", "doc/EXAMPLE_03_STOCKS", "doc/EXAMPLE_04_MULTICLOCK", "doc/EXAMPLE_05_ACK", "doc/EXAMPLE_05_POP", "doc/EXAMPLE_06_HASHTABLE"]
  s.files = ["README", "doc/EXAMPLE_01_PINGPONG", "doc/EXAMPLE_02_CLOCK", "doc/EXAMPLE_03_STOCKS", "doc/EXAMPLE_04_MULTICLOCK", "doc/EXAMPLE_05_ACK", "doc/EXAMPLE_05_POP", "doc/EXAMPLE_06_HASHTABLE"]
  s.homepage = "http://amqp.rubyforge.org/"
  s.rdoc_options = ["--include=examples"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "amqp"
  s.rubygems_version = "1.8.21"
  s.summary = "AMQP client implementation in Ruby/EventMachine"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0.12.4"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0.12.4"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0.12.4"])
  end
end
