# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "servolux"
  s.version = "0.9.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Pease"]
  s.date = "2011-01-02"
  s.description = "Serv-O-Lux is a collection of Ruby classes that are useful for daemon and\nprocess management, and for writing your own Ruby services. The code is well\ndocumented and tested. It works with Ruby and JRuby supporing both 1.8 and 1.9\ninterpreters."
  s.email = "tim.pease@gmail.com"
  s.extra_rdoc_files = ["History.txt", "README.rdoc", "version.txt"]
  s.files = ["History.txt", "README.rdoc", "version.txt"]
  s.homepage = "http://gemcutter.org/gems/servolux"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "servolux"
  s.rubygems_version = "1.8.10"
  s.summary = "Serv-O-Lux is a collection of Ruby classes that are useful for daemon and process management, and for writing your own Ruby services."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bones-rspec>, [">= 1.1.0"])
      s.add_development_dependency(%q<bones-git>, [">= 1.2.2"])
      s.add_development_dependency(%q<logging>, [">= 1.4.3"])
      s.add_development_dependency(%q<bones>, [">= 3.5.4"])
    else
      s.add_dependency(%q<bones-rspec>, [">= 1.1.0"])
      s.add_dependency(%q<bones-git>, [">= 1.2.2"])
      s.add_dependency(%q<logging>, [">= 1.4.3"])
      s.add_dependency(%q<bones>, [">= 3.5.4"])
    end
  else
    s.add_dependency(%q<bones-rspec>, [">= 1.1.0"])
    s.add_dependency(%q<bones-git>, [">= 1.2.2"])
    s.add_dependency(%q<logging>, [">= 1.4.3"])
    s.add_dependency(%q<bones>, [">= 3.5.4"])
  end
end
