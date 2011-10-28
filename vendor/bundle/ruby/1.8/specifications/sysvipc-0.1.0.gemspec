# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sysvipc"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["name"]
  s.date = "2009-09-24"
  s.description = "FIX (describe your package)"
  s.email = ["email"]
  s.homepage = "http://github.com/\#{github_username}/\#{project_name}"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = "sysvipc"
  s.rubygems_version = "1.8.10"
  s.summary = "FIX (describe your package)"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.2"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.2"])
  end
end
