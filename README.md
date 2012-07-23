Semantic
========

A small Ruby utility class to aid in the storage, parsing, and comparison of SemVer-style Version strings.

See [the SemVer site](http://semver.org) for more details.

Usage
-----

This library exposes a single class – `Semantic::Version`. Simply pass in a valid SemVer string to
the initializer.

```ruby
require 'semantic'

version = Semantic::Version.new '1.6.5'
version.major             # => 1
version.minor             # => 6
version.patch             # => 5

newer_version = Semantic::Version.new '1.7.0'
version > newer_version   # => false
newer_version <=> version # => 1
```

There is also a set of core extensions as an optional require:

```ruby
require 'semantic'
require 'semantic/core_ext'

"1.8.7-pre.123".to_version
```

License
-------
Copyright (c) 2012 Josh Lindsey. See LICENSE for details.

