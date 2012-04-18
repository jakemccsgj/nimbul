# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "emissary"
  s.version = "1.3.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Carl P. Corliss"]
  s.date = "2011-06-15"
  s.email = "carl.corliss@nytimes.com"
  s.executables = ["emissary-setup", "emissary-send-message", "emissary", "amqp-listen"]
  s.extra_rdoc_files = ["README.txt"]
  s.files = ["bin/emissary-setup", "bin/emissary-send-message", "bin/emissary", "bin/amqp-listen", "README.txt"]
  s.homepage = "http://www.nytimes.com/"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.21"
  s.summary = "EventMachine/AMQP based event handling client"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<daemons>, [">= 1.0.10"])
      s.add_runtime_dependency(%q<inifile>, [">= 0.3.0"])
      s.add_runtime_dependency(%q<sys-cpu>, [">= 0.6.2"])
      s.add_runtime_dependency(%q<bert>, [">= 1.1.2"])
      s.add_runtime_dependency(%q<amqp>, ["= 0.6.7"])
      s.add_runtime_dependency(%q<carrot>, [">= 0.8.1"])
      s.add_runtime_dependency(%q<eventmachine>, [">= 0.12.10"])
      s.add_runtime_dependency(%q<servolux>, [">= 0.9.4"])
      s.add_runtime_dependency(%q<uuid>, [">= 2.3.0"])
      s.add_runtime_dependency(%q<work_queue>, [">= 1.0.0"])
    else
      s.add_dependency(%q<daemons>, [">= 1.0.10"])
      s.add_dependency(%q<inifile>, [">= 0.3.0"])
      s.add_dependency(%q<sys-cpu>, [">= 0.6.2"])
      s.add_dependency(%q<bert>, [">= 1.1.2"])
      s.add_dependency(%q<amqp>, ["= 0.6.7"])
      s.add_dependency(%q<carrot>, [">= 0.8.1"])
      s.add_dependency(%q<eventmachine>, [">= 0.12.10"])
      s.add_dependency(%q<servolux>, [">= 0.9.4"])
      s.add_dependency(%q<uuid>, [">= 2.3.0"])
      s.add_dependency(%q<work_queue>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<daemons>, [">= 1.0.10"])
    s.add_dependency(%q<inifile>, [">= 0.3.0"])
    s.add_dependency(%q<sys-cpu>, [">= 0.6.2"])
    s.add_dependency(%q<bert>, [">= 1.1.2"])
    s.add_dependency(%q<amqp>, ["= 0.6.7"])
    s.add_dependency(%q<carrot>, [">= 0.8.1"])
    s.add_dependency(%q<eventmachine>, [">= 0.12.10"])
    s.add_dependency(%q<servolux>, [">= 0.9.4"])
    s.add_dependency(%q<uuid>, [">= 2.3.0"])
    s.add_dependency(%q<work_queue>, [">= 1.0.0"])
  end
end
