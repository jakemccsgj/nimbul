inifile [![Build Status](https://secure.travis-ci.org/TwP/inifile.png)](http://travis-ci.org/TwP/inifile)
=======

This is a native Ruby package for reading and writing INI files.


Description
-----------

Although made popular by Windows, INI files can be used on any system thanks
to their flexibility. They allow a program to store configuration data, which
can then be easily parsed and changed. Two notable systems that use the INI
format are Samba and Trac.

More information about INI files can be found on the [Wikipedia Page](http://en.wikipedia.org/wiki/INI_file).

### Properties

The basic element contained in an INI file is the property. Every property has
a name and a value, delimited by an equals sign *=*. The name appears to the
left of the equals sign and the value to the right.

    name=value

### Sections

Section declarations start with *[* and end with *]* as in `[section1]` and
`[section2]` shown in the example below. The section declaration marks the
beginning of a section. All properties after the section declaration will be
associated with that section.

### Comments

All lines beginning with a semicolon *;* or a number sign *#* are considered
to be comments. Comment lines are ignored when parsing INI files.

### Example File Format

A typical INI file might look like this:

    [section1]
    ; some comment on section1
    var1 = foo
    var2 = doodle
    var3 = multiline values \
    are also possible

    [section2]
    # another comment
    var1 = baz
    var2 = shoodle


Implementation
--------------

The format of INI files is not well defined. Several assumptions are made by
the **inifile** gem when parsing INI files. Most of these assumptions can be
modified at, but the defaults are listed below.

### Global Properties

If the INI file lacks any section declarations, or if there are properties
decalared before the first section, then these properties will be placed into
a default "global" section. The name of this section can be configured when
creating an `IniFile` instance.

### Duplicate Properties

Duplicate properties are allowed in a single section. The last property value
set is the one that will be stored in the `IniFile` instance.

    [section1]
    var1 = foo
    var2 = bar
    var1 = poodle

The resulting value of `var1` will be `poodle`.

### Duplicate Sections

If you have more than one section with the same name then the sections will be
merged. Duplicate properties between the two sections will follow the rules
discussed above. Properties in the latter section will override properties in
the earlier section.

### Comments

The comment character can be either a semicolon *;* or a number sign *#*. The
comment character must be the first non-whitespace character on the line. This
means it is perfectly valid to include a comment character inside a **value**
or event a property **name** (although this is not recommended). For this
reason, comments cannot be placed on the end of a line after a name/value
pair.

### Escape Characters

Several escape characters are supported within the **value** for a property.
Most notably, a backslash *\* at the end of a line will continue the value
onto the next line. When parsed, a literal newline will appear in the value.

* \0 -- null character
* \n -- newline character
* \r -- carriage return character
* \t -- tab character
* \\\\ -- backslash character

The backslash escape sequence is only needed if you want one of the escape
sequences to appear literally in your value. For example:

    property=this is not a tab \\t character


Install
-------

    gem install inifile


Testing
-------

To run the tests:

    $ rake


Contributing
------------

Contributions are gladly welcome! For small modifications (fixing typos,
improving documentation) you can use GitHub's in-browser editing capabilities
to create a pull request. For larger modifications I would recommend forking
the project, creating your patch, and then submitting a pull request.

Mr Bones is used to manage rake tasks and to install dependent files. To setup
your environment ...

    $ gem install bones
    $ rake gem:install_dependencies

And always remember that `rake -T` will show you the list of available tasks.


License
-------

MIT License
Copyright (c) 2006 - 2012

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
