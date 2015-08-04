#
# Author:: BinaryBabel OSS (<projects@binarybabel.org>)
# Homepage:: http://www.binarybabel.org
# License:: MIT
#
# For bugs, docs, updates:
#
#     http://code.binbab.org
#
# Copyright 2013 sha1(OWNER) = df334a7237f10846a0ca302bd323e35ee1463931
#
# See LICENSE file for more details.
#

require 'vagrant-wrapper/exceptions'

# Main class for the VagrantWrapper driver.
# This driver will search predefined paths for a packaged version of Vagrant,
# followed by the system's environment PATH. Ideal functionality being that
# a stale Gem version of Vagrant will be overriden by the packaged version
# if the vagrant-wrapper Gem is required in your bundle.
class VagrantWrapper

  # The string used to detect ourselves and a gem wrapper of ourselves
  WRAPPER_MARK = "vagrant-wrapper"

  def initialize(*args)
    @vagrant_name = windows? ? "vagrant.exe" : "vagrant"
    @vagrant_path = nil
    @search_paths = default_paths + env_paths

    # Optional first parameter sets required version.
    unless args.length < 1 or args[0].nil?
      require_version args[0]
    end
  end

  # Require a specific version (or range of versions).
  # Ex. ">= 1.1"
  def require_version(version)
    version_req = Gem::Requirement.new(version)
    vagrant_ver = vagrant_version
    raise Exceptions::NotInstalled, "Vagrant is not installed." if vagrant_ver.nil?
    unless version_req.satisfied_by?(Gem::Version.new(vagrant_ver))
      raise Exceptions::Version, "Vagrant #{version} is required. You have #{vagrant_ver}."
    end
  end

  # Call the discovered version of Vagrant.
  # The given arguments (if any) are passed along to the command line.
  #
  # The output will be returned.
  def get_output(*args)
    if args.length > 0 && args[0].is_a?(Array)
      send("call_vagrant", *args[0])
    else
      send("call_vagrant", *args)
    end
  end

  # Execute the discovered version of Vagrant.
  # The given arguments (if any) are passed along to the command line.
  #
  # The vagrant process will replace this process entirely, operating
  # and outputting in an unmodified state.
  def execute(*args)
    if args.length > 0 && args[0].is_a?(Array)
      send("exec_vagrant", *args[0])
    else
      send("exec_vagrant", *args)
    end
  end

  # Return the filesystem location of the discovered Vagrant install.
  def vagrant_location
    find_vagrant
  end

  # Return the version of the discovered Vagrant install.
  def vagrant_version
    ver = call_vagrant "-v"
    unless ver.nil?
      ver = ver[/Vagrant( version)? ([0-9]+(\.[0-9]+)+)/, 2]
    end
    ver
  end

  # Default paths to search for the packaged version of Vagrant.
  #   /opt/vagrant/bin
  #   /usr/local/bin
  #   /usr/bin
  #   /bin
  def default_paths
    if windows?
      %w{
        C:\HashiCorp\Vagrant\bin
        /c/HashiCorp/Vagrant/bin
      }
    else
      %w{
        /opt/vagrant/bin
        /usr/local/bin
        /usr/bin
        /bin
      }
    end
  end

  # Environment search paths to be used as low priority search.
  def env_paths
    path = ENV['PATH'].to_s.strip
    return [] if path.empty?
    separator = if windows?
                  ';'
                else
                  ':'
                end
    path.split(separator)
  end

  def self.install_instructions
    "See http://www.vagrantup.com for instructions.\n"
  end

  def self.require_or_help_install(version)
    begin
      vw = VagrantWrapper.new(version)
    rescue Exceptions::Version => e
      $stderr.print e.message + "\n"
      $stderr.print install_instructions
      exit(1)
    end
    vw
  end

  protected

  attr_accessor :search_paths

  # Locate the installed version of Vagrant using the provided paths.
  # Exclude the wrapper itself, should it be discovered by the search.
  def find_vagrant
    unless @vagrant_path
      @search_paths.each do |path|
        test_bin = "#{path}#{path_separator}#{@vagrant_name}"
        next unless ::File.executable?(test_bin)
        next if is_wrapper?(test_bin)
        @vagrant_path = test_bin
        break
      end
    end
    @vagrant_path
  end

  # Call Vagrant once and return the output of the command.
  def call_vagrant(*args)
    unless vagrant = find_vagrant
      return nil
    end
    args.unshift(vagrant)
    %x{#{args.join(' ')} 2>&1}
  end

  # Give execution control to Vagrant.
  def exec_vagrant(*args)
    unless vagrant = find_vagrant
      $stderr.puts "Vagrant is not installed."
      $stderr.print VagrantWrapper.install_instructions
      exit(1)
    end
    exec(vagrant, *args)
  end

  def windows?
    !!(RUBY_PLATFORM =~ /mswin|mingw|windows/)
  end

  def is_wrapper?(file)
    File.binread(file).include?(WRAPPER_MARK)
  end

  def path_separator
    if windows?
      File::ALT_SEPARATOR || '\\'.freeze
    else
      File::SEPARATOR
    end
  end
end
