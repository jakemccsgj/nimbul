# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "inifile"
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Pease"]
  s.date = "2012-02-28"
  s.description = "Although made popular by Windows, INI files can be used on any system thanks\nto their flexibility. They allow a program to store configuration data, which\ncan then be easily parsed and changed. Two notable systems that use the INI\nformat are Samba and Trac.\n\nMore information about INI files can be found on the [Wikipedia Page](http://en.wikipedia.org/wiki/INI_file).\n\n### Properties\n\nThe basic element contained in an INI file is the property. Every property has\na name and a value, delimited by an equals sign *=*. The name appears to the\nleft of the equals sign and the value to the right.\n\n    name=value\n\n### Sections\n\nSection declarations start with *[* and end with *]* as in `[section1]` and\n`[section2]` shown in the example below. The section declaration marks the\nbeginning of a section. All properties after the section declaration will be\nassociated with that section.\n\n### Comments\n\nAll lines beginning with a semicolon *;* or a number sign *#* are considered\nto be comments. Comment lines are ignored when parsing INI files.\n\n### Example File Format\n\nA typical INI file might look like this:\n\n    [section1]\n    ; some comment on section1\n    var1 = foo\n    var2 = doodle\n    var3 = multiline values \\\n    are also possible\n\n    [section2]\n    # another comment\n    var1 = baz\n \\   var2 = shoodle"
  s.email = "tim.pease@gmail.com"
  s.extra_rdoc_files = ["History.txt"]
  s.files = ["History.txt"]
  s.homepage = "http://rubygems.org/gems/inifile"
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "inifile"
  s.rubygems_version = "1.8.21"
  s.summary = "INI file reader and writer"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bones-git>, [">= 1.2.5"])
      s.add_development_dependency(%q<bones>, [">= 3.7.2"])
    else
      s.add_dependency(%q<bones-git>, [">= 1.2.5"])
      s.add_dependency(%q<bones>, [">= 3.7.2"])
    end
  else
    s.add_dependency(%q<bones-git>, [">= 1.2.5"])
    s.add_dependency(%q<bones>, [">= 3.7.2"])
  end
end
