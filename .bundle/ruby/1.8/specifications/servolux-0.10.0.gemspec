# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "servolux"
  s.version = "0.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Pease"]
  s.date = "2012-02-18"
  s.description = "Serv-O-Lux is a collection of Ruby classes that are useful for daemon and\nprocess management, and for writing your own Ruby services. The code is well\ndocumented and tested. It works with Ruby and JRuby supporting both 1.8 and 1.9\ninterpreters."
  s.email = "tim.pease@gmail.com"
  s.extra_rdoc_files = ["History.txt", "README.rdoc"]
  s.files = ["History.txt", "README.rdoc"]
  s.homepage = "http://gemcutter.org/gems/servolux"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "servolux"
  s.rubygems_version = "1.8.21"
  s.summary = "* {Homepage}[http://rubygems."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bones-rspec>, [">= 2.0.1"])
      s.add_development_dependency(%q<bones-git>, [">= 1.2.5"])
      s.add_development_dependency(%q<logging>, [">= 1.6.2"])
      s.add_development_dependency(%q<bones>, [">= 3.7.2"])
    else
      s.add_dependency(%q<bones-rspec>, [">= 2.0.1"])
      s.add_dependency(%q<bones-git>, [">= 1.2.5"])
      s.add_dependency(%q<logging>, [">= 1.6.2"])
      s.add_dependency(%q<bones>, [">= 3.7.2"])
    end
  else
    s.add_dependency(%q<bones-rspec>, [">= 2.0.1"])
    s.add_dependency(%q<bones-git>, [">= 1.2.5"])
    s.add_dependency(%q<logging>, [">= 1.6.2"])
    s.add_dependency(%q<bones>, [">= 3.7.2"])
  end
end
