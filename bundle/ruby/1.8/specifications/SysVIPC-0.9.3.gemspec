# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "SysVIPC"
  s.version = "0.9.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steven Jenkins"]
  s.date = "2011-09-02"
  s.description = "System V Inter-Process Communication: message queues, semaphores, and shared memory."
  s.email = "sjenkins@rubyforge.org"
  s.extensions = ["./ext/extconf.rb"]
  s.files = ["./ext/extconf.rb"]
  s.homepage = "http://rubyforge.org/projects/sysvipc/"
  s.rdoc_options = ["--title", "SysVIPC"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "sysvipc"
  s.rubygems_version = "1.8.10"
  s.summary = "Builders for MarkUp."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
