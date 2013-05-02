# Vagrant Wrapper Gem

A gem providing access and bundling to the newer packaged versions of Vagrant. (I.E. Vagrant 1.1+)

- Allow your projects to depend on newer versions of Vagrant.
- Ensure shell calls are routed to the packaged version (even if the older Gem version is installed).
- Easily check and enforce version requirements.

**Please note:** this Gem does not install any version of Vagrant, it provides a compatibility layer over the newer packaged version. However, functions are included which may be used to guide the installation of Vagrant, when necessary.

**[More information on why this Gem exists can be seen in the Background section below.](#background---aka-the-vagrant-gem-enigma)**


# Installation and Usage

Require the Vagrant Wrapper via your Gemfile, then run `bundle install`.

    source 'https://rubygems.org'

    gem 'vagrant-wrapper'

Shell calls to 'vagrant' in your project will now always use the packaged version of Vagrant if available,
even if the now deprecated Vagrant Gem is installed and available in your Rubygems path.

Existing projects which require the old 'vagrant' gem in their Gemfile directly will continue to see
and use the older Gem version, even if they are shelling out as well.

**Please note:** The wrapper searches for a packaged installation of Vagrant first, and then falls back to any version it can find in the PATH. Therefore it will link to the 1.0.x gem version if that's all that is installed, so you should always enforce a minimum Vagrant version, see below.


## Gemfile examples

**Let's assume you have both Vagrant 1.0.7 installed via a Gem, and Vagrant 1.2 installed via the official package.**

### A... Older 'vagrant' gemfiles

This older Gemfile will still launch Vagrant 1.0.7, as expected:

**Gemfile**

    source 'https://rubygems.org'
    gem 'vagrant'

**Output**

    puts %x{vagrant -v}
    => "Vagrant version 1.0.7"

_Notes below on [VAGRANT_HOME](#vagrant_home) with older versions._

### B... Simply Leaving out 'vagrant'

This is the key problem the Vagrant Wrapper seeks to solve, because otherwise (without uninstalling the vagrant gem), your shell calls will still be routed to 1.0.7.

**Gemfile**

    source 'https://rubygems.org'

**Output**

    puts %x{vagrant -v}
    => "Vagrant version 1.0.7"

### C... Including 'vagrant-wrapper'

Calls to vagrant now route to the newer packaged version.

**Gemfile**

    source 'https://rubygems.org'
    gem 'vagrant-wrapper'

**Output**

    puts %x{vagrant -v}
    => "Vagrant version 1.2.0"


## Shell interaction

By requiring 'vagrant-wrapper' in your Gemfile, all calls to vagrant (inside and outside of Ruby), will use the packaged Vagrant install if available.

Simply call `vagrant` via a Ruby back tick, or from the command line.


### Requiring a specific version (shell out)

If Vagrant is missing (or older than a version you specify) the command will return a standard-error message:

	Vagrant >= 1.1 is required. You have 1.0.7.
	See http://www.vagrantup.com for instructions.

Ruby

	%x{vagrant --min-ver=1.1 box list}
	
Bash
	
	bundle exec vagrant --min-ver=1.1 box list
	

## Ruby interaction

Ruby functions exist for even deeper integration. For full documentation, please see the [RDoc](http://rubydoc.info/gems/vagrant-wrapper).

### Requiring a specific version (Ruby)

```ruby
 require 'vagrant-wrapper'
    
 # Will throw VagrantWrapper::Exceptions::Version
 vw = VagrantWrapper.new(">= 1.1")
    
 # This does the same thing:
 vw = VagrantWrapper.new
 vw.require_version(">= 1.1.")
```
    
### Handle a missing version

```ruby
 # You could handle the error like this:
 begin
   vw = VagrantWrapper.new(">= 1.1")
 rescue VagrantWrapper::Exceptions::Version => e
   $stderr.print e.message + "\n"
   $stderr.print vw.install_instructions
   exit(1)
 end
 
 # Which is the same as:
 VagrantWrapper.require_or_help_install(">= 1.1")
```

### Getting the current version

```ruby
 require 'vagrant-wrapper'
 VagrantWrapper.new.vagrant_version
 # => "1.1.5"  (nil if not installed)
```
    
### Getting the output of a call to vagrant

```ruby
 require 'vagrant-wrapper'
 box_list = VagrantWrapper.new.get_output "box list"
```
    
### Handing process control to vagrant

This will cause vagrant to become the main process, as if you'd called it on the command-line. Execution will not return to your Ruby script.

```ruby
 require 'vagrant-wrapper'
 VagrantWrapper.new.execute "up"
 puts "This line would never be printed."
```


## Versioning

Please note, the version of this wrapper does not indicate (or mandate) any specific version of Vagrant
on the target system. As above, use the VagrantWrapper API for managing the vagrant version.

It's okay if the 'vagrant-wrapper' gem's version does not match the desired version of Vagrant. Therefore specifying a version of the wrapper in your Gemfile is not recommended.

### VAGRANT_HOME

Major differences in Vagrant will refuse to use the same existing shared data directory. If you have an older project requiring the 'vagrant' gem that's fine, but you may need to set the VAGRANT_HOME environment variable to point to another location.

    $ export VAGRANT_HOME=~/.vagrant.old

----------

# Background - AKA the Vagrant Gem enigma

Per the creator's discretion, Vagrant 1.1+ no longer ships in Gem form,
[see here](https://groups.google.com/d/msg/vagrant-up/kX_wvn7wcds/luwNur4kgDEJ),
in favor of packaged installers.

There are many ways in which this is a strong move for the project, and in theory Vagrant's ability to use
its own bundled Ruby allows it to operate in a vacuum. So why does this wrapper exist?

The problem is that Gems do (and will always) exist for the older versions. If they are installed they tend
to override the system installed version of Vagrant if shell calls are made from within Ruby projects.

As an example, if you have any bundled project that requires the 'vagrant' gem via its Gemfile, and a newer
project that does not require this Gem (hoping to rely on the system packaged version), you'll find that
the Gem version of Vagrant will always be called when your program attempts to access Vagrant via a shell
or subprocess.

This is because the Rubygems bin directory is higher in your PATH, and using "bundle exec" will not help.
Even though Bundler will attempt to broker between multiple versions of Gems, it cannot handle the choice
between the Gem version and the system version.

Your only option would be to remove the old vagrant gem between projects, which is cumbersome. Also the problem will recur if you run a "bundle install" on a project which still includes the older Gem. This wrapper
solves the problem by giving your newer projects something to include and override the older Gem versions
of Vagrant.

----------

# Development and Maintenance

* Found a bug?
* Need some help?
* Have a suggestion?
* Want to contribute?

Please visit: [code.binbab.org](http://code.binbab.org)


## Integration Testing

    bundle install
    rake test


# Authors and License

* Author:: BinaryBabel OSS (<projects@binarybabel.org>)
* Copyright:: 2013 `sha1(OWNER) = df334a7237f10846a0ca302bd323e35ee1463931`
* License:: MIT
