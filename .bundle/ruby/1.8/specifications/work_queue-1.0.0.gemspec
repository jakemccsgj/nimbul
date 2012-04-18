# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "work_queue"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Miguel Fonseca"]
  s.date = "2010-02-16"
  s.email = "fmmfonseca@gmail.com"
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["README.rdoc", "LICENSE"]
  s.homepage = "http://github.com/fmmfonseca/work_queue"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.6")
  s.rubygems_version = "1.8.21"
  s.summary = "A tunable work queue, designed to coordinate work between a producer and a pool of worker threads."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
