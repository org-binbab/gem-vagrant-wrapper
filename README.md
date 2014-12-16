# Vagrant Wrapper Gem

A gem providing access and bundling to the newer packaged versions of Vagrant. (I.E. Vagrant 1.1+)

- Allow your projects to depend on newer versions of Vagrant.
- Ensure shell calls are routed to the packaged version (even if the older Gem version is installed).
- Easily check and enforce version requirements.

**Please note:** this Gem does not install any version of Vagrant, it provides a compatibility layer over the newer packaged version. However, functions are included which may be used to guide the installation of Vagrant, when necessary.

### Background - AKA the Vagrant Gem Enigma

Examples of the problem this gem solves, and the history behind it, have been moved to the [ENIGMA.md](ENIGMA.md) file.

## Version 2.0 Now Available

- Now supporting Windows!
- Testing cleaned up and updated to RSpec3

Big thank you to @btm for writing these updates, and @tknerr for helping to test.



# Installation and Usage

Require the Vagrant Wrapper via your Gemfile, then run `bundle install`.

    gem 'vagrant-wrapper'

Shell calls to 'vagrant' in your project will now always use the packaged version of Vagrant if available,
even if the now deprecated Vagrant Gem is installed and available in your Rubygems path.

Existing projects which require the old 'vagrant' gem in their Gemfile directly will continue to see
and use the older Gem version, even if they are shelling out as well.

**Please note:** The wrapper searches for a packaged installation of Vagrant first, and then falls back to any version it can find in the PATH. Therefore it will link to the 1.0.x gem version if that's all that is installed, so you should always enforce a minimum Vagrant version, see below.


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
