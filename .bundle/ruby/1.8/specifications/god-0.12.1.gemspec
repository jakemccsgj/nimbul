# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "god"
  s.version = "0.12.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Preston-Werner", "Kevin Clark", "Eric Lindvall"]
  s.date = "2012-01-21"
  s.description = "An easy to configure, easy to extend monitoring framework written in Ruby."
  s.email = "god-rb@googlegroups.com"
  s.executables = ["god"]
  s.extensions = ["ext/god/extconf.rb"]
  s.extra_rdoc_files = ["README.md"]
  s.files = ["bin/god", "README.md", "ext/god/extconf.rb"]
  s.homepage = "http://god.rubyforge.org/"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = "god"
  s.rubygems_version = "1.8.21"
  s.summary = "Process monitoring framework."

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<json>, ["~> 1.6"])
      s.add_development_dependency(%q<rake>, ["~> 0.9"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<twitter>, ["~> 2.0"])
      s.add_development_dependency(%q<prowly>, ["~> 0.3"])
      s.add_development_dependency(%q<xmpp4r>, ["~> 0.5"])
      s.add_development_dependency(%q<dike>, ["~> 0.0.3"])
      s.add_development_dependency(%q<snapshot>, ["~> 1.0"])
      s.add_development_dependency(%q<rcov>, ["~> 0.9"])
      s.add_development_dependency(%q<daemons>, ["~> 1.1"])
      s.add_development_dependency(%q<mocha>, ["~> 0.10"])
      s.add_development_dependency(%q<gollum>, ["~> 1.3.1"])
    else
      s.add_dependency(%q<json>, ["~> 1.6"])
      s.add_dependency(%q<rake>, ["~> 0.9"])
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<twitter>, ["~> 2.0"])
      s.add_dependency(%q<prowly>, ["~> 0.3"])
      s.add_dependency(%q<xmpp4r>, ["~> 0.5"])
      s.add_dependency(%q<dike>, ["~> 0.0.3"])
      s.add_dependency(%q<snapshot>, ["~> 1.0"])
      s.add_dependency(%q<rcov>, ["~> 0.9"])
      s.add_dependency(%q<daemons>, ["~> 1.1"])
      s.add_dependency(%q<mocha>, ["~> 0.10"])
      s.add_dependency(%q<gollum>, ["~> 1.3.1"])
    end
  else
    s.add_dependency(%q<json>, ["~> 1.6"])
    s.add_dependency(%q<rake>, ["~> 0.9"])
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<twitter>, ["~> 2.0"])
    s.add_dependency(%q<prowly>, ["~> 0.3"])
    s.add_dependency(%q<xmpp4r>, ["~> 0.5"])
    s.add_dependency(%q<dike>, ["~> 0.0.3"])
    s.add_dependency(%q<snapshot>, ["~> 1.0"])
    s.add_dependency(%q<rcov>, ["~> 0.9"])
    s.add_dependency(%q<daemons>, ["~> 1.1"])
    s.add_dependency(%q<mocha>, ["~> 0.10"])
    s.add_dependency(%q<gollum>, ["~> 1.3.1"])
  end
end
