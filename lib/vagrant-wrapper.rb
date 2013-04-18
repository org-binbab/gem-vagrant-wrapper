require 'Shellwords'

# Main class for the VagrantWrapper driver.
# This driver will search predefined paths for a packaged version of Vagrant,
# followed by the system's environment PATH. Ideal functionality being that
# a stale Gem version of Vagrant will be overriden by the packaged version
# if the vagrant-wrapper Gem is required in your bundle.
class VagrantWrapper

  def initialize
    @vagrant_name = "vagrant"
    @vagrant_path = nil
    @search_paths = default_paths
    @wrapper_mark = "END VAGRANT WRAPPER"

    # Include environment paths as low priority searches.
    env_path = ENV['PATH'].to_s
    if "" != env_path
      @search_paths.concat(env_path.split(':'))
    end
  end

  # Call the discovered version of Vagrant.
  # The given arguments (if any) are passed along to the command line.
  #
  # The output will be returned.
  def execute(*args)
    if args.length > 0 && args[0].is_a?(Array)
      send("exec_vagrant", *args[0])
    else
      send("exec_vagrant", *args)
    end
  end

  # Execute the discovered version of Vagrant.
  # The given arguments (if any) are passed along to the command line.
  #
  # The vagrant process will replace this processe entirely, operating
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
  
  # Return the version of the discovered Vagrent install.
  def vagrant_version
    ver = call_vagrant "-v"
    unless ver.nil?
      ver = ver[/(\.?[0-9]+)+/]
    end
    ver
  end

  # Default paths to search for the packaged version of Vagrant.
  #   /opt/vagrant/bin
  #   /usr/local/bin
  #   /usr/bin
  #   /bin
  def default_paths
    %w{
      /opt/vagrant/bin
      /usr/local/bin
      /usr/bin
      /bin
    }
  end

  protected

  # Locate the installed version of Vagrant using the provided paths.
  # Exclude the wrapper itself, should it be discovered by the search.
  def find_vagrant
    unless @vagrant_path
      @search_paths.each do |path|
        test_bin = "#{path}/#{@vagrant_name}"
        next unless ::File.executable?(test_bin)
        next if (%x{tail -n1 #{test_bin}}.match(@wrapper_mark) != nil)
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
    %x{#{Shellwords.join(args)} + ' 2>&1'}
  end

  # Give execution control to Vagrant.
  def exec_vagrant(*args)
    unless vagrant = find_vagrant
      $stderr.puts "Vagrant does not appear to be installed."
      $stderr.puts "See http://www.vagrantup.com for instructions."
      exit(1)
    end
    args.unshift(vagrant)
    exec(Shellwords.join(args))
  end
end
