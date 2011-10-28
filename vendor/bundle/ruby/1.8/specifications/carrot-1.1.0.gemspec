# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "carrot"
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Amos Elliston"]
  s.date = "2011-10-07"
  s.description = "A synchronous version of the ruby amqp client"
  s.email = "amos@geni.com"
  s.extra_rdoc_files = ["LICENSE", "README.markdown"]
  s.files = ["LICENSE", "README.markdown"]
  s.homepage = "http://github.com/famoseagle/carrot"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "A synchronous version of the ruby amqp client"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
