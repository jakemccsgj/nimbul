# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "bert"
  s.version = "1.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Preston-Werner"]
  s.date = "2010-02-08"
  s.description = "BERT Serializiation for Ruby"
  s.email = "tom@mojombo.com"
  s.extensions = ["ext/bert/c/extconf.rb", "ext/bert/c/extconf.rb"]
  s.extra_rdoc_files = ["LICENSE", "README.md"]
  s.files = ["LICENSE", "README.md", "ext/bert/c/extconf.rb"]
  s.homepage = "http://github.com/mojombo/bert"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib", "ext"]
  s.rubygems_version = "1.8.21"
  s.summary = "BERT Serializiation for Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  end
end
