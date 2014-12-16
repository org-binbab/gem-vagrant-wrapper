# Background - AKA the Vagrant Gem Enigma


## Gemfile examples illustrating the problem this gem solves

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


## How this problem came to be

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
