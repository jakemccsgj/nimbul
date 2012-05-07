# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "inifile"
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Pease"]
  s.date = "2011-02-22"
  s.description = "This is a native Ruby package for reading and writing INI files.\n\nAlthough made popular by Windows, INI files can be used on any system thanks\nto their flexibility. They allow a program to store configuration data, which\ncan then be easily parsed and changed. Two notable systems that use the INI\nformat are Samba and Trac.\n\n== SYNOPSIS:\n\nAn initialization file, or INI file, is a configuration file that contains\nconfiguration data for Microsoft Windows based applications. Starting with\nWindows 95, the INI file format was superseded but not entirely replaced by\na registry database in Microsoft operating systems.\n\nAlthough made popular by Windows, INI files can be used on any system thanks\nto their flexibility. They allow a program to store configuration data, which\ncan then be easily parsed and changed."
  s.email = "tim.pease@gmail.com"
  s.extra_rdoc_files = ["History.txt", "README.txt"]
  s.files = ["History.txt", "README.txt"]
  s.homepage = "http://gemcutter.org/gems/inifile"
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "inifile"
  s.rubygems_version = "1.8.21"
  s.summary = "INI file reader and writer"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bones-git>, [">= 1.2.4"])
      s.add_development_dependency(%q<bones>, [">= 3.6.5"])
    else
      s.add_dependency(%q<bones-git>, [">= 1.2.4"])
      s.add_dependency(%q<bones>, [">= 3.6.5"])
    end
  else
    s.add_dependency(%q<bones-git>, [">= 1.2.4"])
    s.add_dependency(%q<bones>, [">= 3.6.5"])
  end
end
