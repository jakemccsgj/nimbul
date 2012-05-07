# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "activemessaging"
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jon Tirsen", "Andrew Kuklewicz", "Olle Jonsson", "Sylvain Perez", "Cliff Moon", "Uwe Kubosch"]
  s.date = "2011-12-05"
  s.description = "ActiveMessaging is an attempt to bring the simplicity and elegance of rails development to the world of messaging. Messaging, (or event-driven architecture) is widely used for enterprise integration, with frameworks such as Java's JMS, and products such as ActiveMQ, Tibco, IBM MQSeries, etc. Now supporting Rails 3 as of version 0.8.0."
  s.email = "activemessaging-discuss@googlegroups.com"
  s.extra_rdoc_files = ["README"]
  s.files = ["README"]
  s.homepage = "http://github.com/kookster/activemessaging"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.21"
  s.summary = "Official activemessaging gem, now hosted on github.com/kookster. (kookster prefix temporary)"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 1.0.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 1.0.0"])
  end
end
