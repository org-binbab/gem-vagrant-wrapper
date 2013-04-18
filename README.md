# Vagrant Wrapper Gem

Per the creator's discretion, Vagrant 1.1+ no longer ships in Gem form,
[see here](https://groups.google.com/d/msg/vagrant-up/kX_wvn7wcds/luwNur4kgDEJ),
in favor of packaged installers.

There are many ways in which this is a strong move for the project, and in theory Vagrant's ability to use
its own bundled Ruby allows it to operate in a vacuum. So why does this wrapper exist?

The problem is that Gems do (and will always) exist for the older versions. If they are installed they tend
to override the system installed version of Vagrant.

As an example, if you have any bundled project that requires the "vagrant" gem via its Gemfile, and a newer
project that does not require this Gem (hoping to rely on the system packaged version), you'll find that
the Gem version of Vagrant will always be called when your program attempts to access Vagrant via a shell
or subprocess.

This is because the Rubygems bin directory is higher in your PATH, and using "bundle exec" will not help.
Even though Bundler will attempt to broker between multiple versions of Gems, it cannot handle the choice
between the Gem version and the system version.

Your only option would be to remove the old vagrant gem between projects, which is cumbersome. This wrapper
solves the problem by giving your newer projects something to include and override the older Gem versions
of Vagrant.

## Installation and Usage

Require the Vagrant Wrapper via your Gemfile

    source 'https://rubygems.org'

    gem 'vagrant-wrapper'

Any shell calls to "vagrant" in your project will now use the packaged version of Vagrant if available,
even if the now deprecated Vagrant gem is installed and available in your Rubygems path.

Existing projects which require the old "vagrant" gem in their Gemfile directly will continue to see
and use the older Gem version, even if they are shelling out as well.

## Versioning

Please note, the version of this wrapper does not indicate (nor mandate) any specific version of Vagrant
on the target system. Its selection process is simpy to prefer the packaged vagrant over the old Gem
distribution. Therefore it will not need updated with Vagrant, and specifying a version of the
wrapper in your Gemfile is not recommended.

As such, you should continue to treat Vagrant as an external system plugin, and test accordingly.

You can however use the Vagrant Wrapper's API to facilitate checking the availability.

    require 'vagrant-wrapper'
    VagrantWrapper.new.vagrant_version
    # => "1.1.5"  (nil if not installed)

For more information, see the [Rdoc](http://rubydoc.info/gems/vagrant-wrapper).


## Development and Maintenance

* Found a bug?
* Need some help?
* Have a suggestion?
* Want to contribute?

Please visit: [code.binbab.org](http://code.binbab.org)


## Authors and License

* Author:: BinaryBabel OSS (<projects@binarybabel.org>)
* Copyright:: 2013 `sha1(OWNER) = df334a7237f10846a0ca302bd323e35ee1463931`
* License:: MIT
