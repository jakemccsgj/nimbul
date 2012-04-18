# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "wirble"
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Duncan"]
  s.autorequire = "wirble"
  s.date = "2009-05-30"
  s.description = "Handful of common Irb features, made easy."
  s.email = "pabs@pablotron.org"
  s.homepage = "http://pablotron.org/software/wirble/"
  s.rdoc_options = ["--title", "Wirble 0.1.3 API Documentation", "--webcvs", "http://hg.pablotron.org/wirble", "lib/wirble.rb", "README"]
  s.require_paths = ["lib"]
  s.requirements = ["none"]
  s.rubyforge_project = "pablotron"
  s.rubygems_version = "1.8.21"
  s.summary = "Handful of common Irb features, made easy."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
