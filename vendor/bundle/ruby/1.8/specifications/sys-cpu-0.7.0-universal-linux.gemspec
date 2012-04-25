# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sys-cpu"
  s.version = "0.7.0"
  s.platform = "universal-linux"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel J. Berger"]
  s.date = "2011-12-14"
  s.description = "    The sys-cpu library provides an interface for gathering information\n    about your system's processor(s). Information includes speed, type,\n    and load average.\n"
  s.email = "djberg96 at nospam at gmail dot com"
  s.extra_rdoc_files = ["CHANGES", "README", "MANIFEST", "lib/linux/sys/cpu.rb"]
  s.files = ["CHANGES", "README", "MANIFEST", "lib/linux/sys/cpu.rb"]
  s.homepage = "http://www.rubyforge.org/projects/sysutils"
  s.require_paths = ["lib", "lib/linux"]
  s.rubyforge_project = "sysutils"
  s.rubygems_version = "1.8.21"
  s.summary = "A Ruby interface for providing CPU information"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ffi>, [">= 1.0.0"])
      s.add_development_dependency(%q<test-unit>, [">= 2.1.2"])
    else
      s.add_dependency(%q<ffi>, [">= 1.0.0"])
      s.add_dependency(%q<test-unit>, [">= 2.1.2"])
    end
  else
    s.add_dependency(%q<ffi>, [">= 1.0.0"])
    s.add_dependency(%q<test-unit>, [">= 2.1.2"])
  end
end
