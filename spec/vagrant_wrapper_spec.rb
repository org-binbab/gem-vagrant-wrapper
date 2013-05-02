require 'spec_helper'

describe VagrantWrapper do

  before :all do
    @tmp_dir = "#{Dir.tmpdir}/vagrant-wrapper_gemtest"
    @tmp_old_vagrant = "#{@tmp_dir}/vagrant.old"
    @tmp_new_vagrant = "#{@tmp_dir}/vagrant.new"
    [ @tmp_dir, @tmp_old_vagrant, @tmp_new_vagrant ].each do |dir|
      Dir.mkdir(dir) unless Dir.exists?(dir)
    end
  end

  after :all do
    if Dir.exists?(@tmp_dir)
      FileUtils.rm_rf @tmp_dir
    end
  end

  before :each do
    ENV['VAGRANT_HOME'] = @tmp_new_vagrant
    @v = VagrantWrapper.new
  end

  describe "#new" do
    context "with no parameters" do
      it "returns a VagrantWrapper object" do
        @v.should be_an_instance_of VagrantWrapper
      end
    end

    context "with good version parameter" do
      it "should NOT throw a Version exception" do
        expect {
          @v.require_version("> 1.0")
        }.to_not raise_error
      end
    end

    context "with bad version parameter" do
      it "should throw a Version exception" do
        expect {
          @v.require_version(">= 4.0")
        }.to raise_error(VagrantWrapper::Exceptions::Version)
      end
    end
  end  # /#new

  describe "#vagrant_version" do
    context "empty search path" do
      it "returns nil indicating Vagrant not found" do
        @v.send("search_paths=", Array.new)
        @v.vagrant_version.should be_nil
      end
    end

    context "system search path" do
      before :each do
        ENV['VAGRANT_HOME'] = @tmp_old_vagrant
        @v.send("search_paths=", @v.env_paths)
        @version = @v.vagrant_version
      end

      it "returns a valid version" do
        Gem::Version.new(@version).should_not be_nil
      end

      it "returns a version less than 1.1" do
        @version.should_not be_nil
        Gem::Version.new(@version).should be < Gem::Version.new('1.1')
      end
    end

    context "extended search path" do
      before :each do
        @version = @v.vagrant_version
      end

      it "returns a valid version" do
        Gem::Version.new(@version).should_not be_nil
      end

      it "returns a version higher than 1.0" do
        @version.should_not be_nil
        Gem::Version.new(@version).should be >= Gem::Version.new('1.1')
      end
    end
  end  # /#vagrant_version

  describe "#vagrant_location" do
    it "exists and contains vagrant" do
      location = @v.vagrant_location
      location.should match /vagrant$/
      File.exists?(location).should be_true
    end
  end

  describe "#get_output" do
    context "-v" do
      it "should return full version string" do
        output = @v.get_output("-v")
        output.should match /^Vagrant version/
      end
    end
  end

  describe "#require_version" do
    context "with >= 1.1" do
      it "should NOT throw a version exception" do
        expect {
          @v.require_version(">= 1.1")
        }.to_not raise_error
      end
    end

    context "with >= 4.0" do
      it "should throw a Version exception" do
        expect {
          @v.require_version(">= 4.0")
        }.to raise_error(VagrantWrapper::Exceptions::Version)
      end
    end

    context "with < 1.1" do
      it "should throw a Version exception" do
        expect {
          @v.require_version("< 1.1")
        }.to raise_error(VagrantWrapper::Exceptions::Version)
      end
    end

    context "with an empty search path" do
      it "should throw a NotInstalled exception" do
        expect {
          @v.send("search_paths=", Array.new)
          @v.require_version(">= 1.1")
        }.to raise_error(VagrantWrapper::Exceptions::NotInstalled)
      end
    end

  end  # /require_version

end

describe "bin/vagrant" do
  it "should return usage" do
    %x{./bin/vagrant}.should match /^Usage/
  end

  context "-v" do
    it "should return full version string" do
      %x{./bin/vagrant -v}.should match /^Vagrant version/
    end
  end

  context "with good min-ver" do
    it "should return full version string" do
      %x{./bin/vagrant --min-ver=1.0 -v}.should match /^Vagrant version/
      %x{./bin/vagrant -v --min-ver=1.0}.should match /^Vagrant version/
    end
  end

  context "with bad min-ver" do
    it "should print instructions" do
      %x{./bin/vagrant --min-ver=4.0 -v 2>&1}.should match /instructions/
    end
  end
end
