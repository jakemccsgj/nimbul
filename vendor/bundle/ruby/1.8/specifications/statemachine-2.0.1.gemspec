# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "statemachine"
  s.version = "2.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["'Micah Micah'"]
  s.autorequire = "statemachine"
  s.date = "2012-01-01"
  s.description = "Statemachine is a ruby library for building Finite State Machines (FSM), also known as Finite State Automata (FSA)."
  s.email = ["'micah@8thlight.com'"]
  s.homepage = "http://statemachine.rubyforge.org"
  s.require_paths = ["lib"]
  s.rubyforge_project = "statemachine"
  s.rubygems_version = "1.8.21"
  s.summary = "Statemachine-2.0.1 - Statemachine Library for Ruby http://slagyr.github.com/statemachine"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
