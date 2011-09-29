# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "Ruby-MemCache"
  s.version = "0.0.1"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.autorequire = "memcache"
  s.cert_chain = nil
  s.date = "2004-11-15"
  s.email = "ged@FaerieMUD.org"
  s.homepage = "http://www.devEiate.org/code/Ruby-MemCache.html"
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = "1.8.10"
  s.summary = "This is a client library for memcached, a high-performance distributed memory cache."

  if s.respond_to? :specification_version then
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<io-reactor>, ["> 0.0.0"])
    else
      s.add_dependency(%q<io-reactor>, ["> 0.0.0"])
    end
  else
    s.add_dependency(%q<io-reactor>, ["> 0.0.0"])
  end
end
