# Neutron

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'neutron'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install neutron

## Usage

Rake & Neutron sample, which compiles Vala program:

```ruby
# File structure:
#   ./Rakefile
#   src/main.vala
#   src/gui.vala
#   src/http.vala
# Required packages:
#   glib-2.0
#   gtk+-3.0
#   libsoup-2.4
# Target file:
#   ./sample

require 'neutron'
require 'neutron/pkgconf'
require 'neutron/cc'
require 'neutron/valac'

Dir.chdir('src/') # We'll compile our stuff here

# Neutron::PkgConf checks package availability for us
packages = Neutron::PkgConf.new %w[
  glib-2.0
  gtk+-3.0
  libsoup-2.4
]

task :default => :build
task :build => %w[valac link]

# Compile our sources. Will not compile already compiled
# files because Neutron.files() excludes them
task :valac do
  Neutron::Valac.compile(
    *Neutron.files(Neutron::FileList['*.vala'], '.vala.o').sources, # Sources
    args: packages.to_valac # Provide list of packages to valac
  )
end

# Link .o files and libraries 
task :link do
  # Neutron:CC provides methods for using C and C++ compilers
  Neutron::CC.link(
    *Neutron::FileList['*.vala.o'],     # Object files
    '../sample',                        # Target file
    args: packages.to_cc(cflags: false) # Package list
  )
end
```

## ToDo

0. Docs
1. Gem-like version-checker
2. Shared-Object builder
3. `install` tool (must install headers, binaries, shared objects)
4. Finders for Boost, SFML, Qt, etc

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/handicraftsman/neutron. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

