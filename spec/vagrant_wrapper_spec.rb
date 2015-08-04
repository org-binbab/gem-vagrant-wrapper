# Some of these tests require that vagrant be installed on the local system

require 'spec_helper'

describe VagrantWrapper do

  let(:version_regex) { Regexp.new('^Vagrant (version)?') }

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
        expect(@v).to be_an_instance_of VagrantWrapper
      end
    end

    context "with good version parameter" do
      it "does NOT throw a Version exception" do
        expect {
          @v.require_version("> 1.0")
        }.to_not raise_error
      end
    end

    context "with bad version parameter" do
      it "throws a Version exception" do
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
        expect(@v.vagrant_version).to be_nil
      end
    end

    context "system search path" do
      before :each do
        ENV['VAGRANT_HOME'] = @tmp_old_vagrant
        @v.send("search_paths=", @v.env_paths)
        @version = @v.vagrant_version
      end

      it "returns a valid version" do
        expect(Gem::Version.new(@version)).to_not be_nil
      end

      it "returns a version less than 1.1" do
        pending "missing support files" unless File.exists?("#{@tmp_old_vagrant}/vagrant")

        expect(@version).to_not be_nil
        expect(Gem::Version.new(@version)).to be < Gem::Version.new('1.1')
      end
    end

    context "extended search path" do
      before :each do
        @version = @v.vagrant_version
      end

      it "returns a valid version" do
        expect(Gem::Version.new(@version)).to_not be_nil
      end

      it "returns a version higher than 1.0" do
        expect(@version).to_not be_nil
        expect(Gem::Version.new(@version)).to be >= Gem::Version.new('1.1')
      end
    end
  end  # /#vagrant_version

  describe "#env_paths" do
    it "returns an array from a colon delimited string on linux" do
       allow(ENV).to receive(:[]).with("PATH").and_return("/bin:/sbin:/usr/bin:/usr/sbin")
       allow(@v).to receive(:windows?).and_return(false)
       expect(@v.env_paths).to eq(['/bin', '/sbin', '/usr/bin', '/usr/sbin'])
    end

    it "returns an array from a semi-colon delimited string on windows" do
       allow(ENV).to receive(:[]).with("PATH").and_return('C:\Windows;C:\Windows\System;C:\Utils')
       allow(@v).to receive(:windows?).and_return(true)
       expect(@v.env_paths).to eq(['C:\Windows', 'C:\Windows\System', 'C:\Utils'])
    end
  end
  describe "#vagrant_location" do
    it "exists and contains vagrant" do
      location = @v.vagrant_location
      expect(location).to match(/vagrant(\.exe)?$/)
      expect(File.exists?(location)).to be true
    end
  end

  describe "#get_output" do
    context "-v" do
      it "returns the full version string" do
        output = @v.get_output("-v")
        expect(output).to match(version_regex)
      end
    end
  end

  describe "#require_version" do
    context "with >= 1.1" do
      it "does NOT throw a version exception" do
        expect {
          @v.require_version(">= 1.1")
        }.to_not raise_error
      end
    end

    context "with >= 4.0" do
      it "throws a Version exception" do
        expect {
          @v.require_version(">= 4.0")
        }.to raise_error(VagrantWrapper::Exceptions::Version)
      end
    end

    context "with < 1.1" do
      it "throws a Version exception" do
        expect {
          @v.require_version("< 1.1")
        }.to raise_error(VagrantWrapper::Exceptions::Version)
      end
    end

    context "with an empty search path" do
      it "throws a NotInstalled exception" do
        expect {
          @v.send("search_paths=", Array.new)
          @v.require_version(">= 1.1")
        }.to raise_error(VagrantWrapper::Exceptions::NotInstalled)
      end
    end

  end  # /require_version

  describe "#default_paths" do
    it "returns an array of paths" do
      expect(@v.default_paths).to be_a(Array)
    end
  end

  describe "#is_wrapper?" do
    let(:temp_file) { Tempfile.new('vagrant_wrapper_spec') }

    after do
      temp_file.unlink
    end

    it "returns true when the file contains the wrapper mark" do
      temp_file.write("This is a temporary file.\n#{VagrantWrapper::WRAPPER_MARK}\nBye.")
      temp_file.close
      expect(@v.send(:is_wrapper?, temp_file.path)).to be true
    end

    it "returns false when the file does not contain the wrapper mark" do
      temp_file.write("This is a temporary file.\nNothing.\nBye.")
      temp_file.close
      expect(@v.send(:is_wrapper?, temp_file.path)).to be false
    end

    it "returns false when the file is binary and does not contain the wrapper mark" do
      # NOTE: this was taken from the actual header of /opt/vagrant/bin/vagrant on an OS X
      # system where vagrant had been installed via "brew cask install brew".
      temp_file.write("\xCF\xFA\xED\xFE\a\u0000\u0000\u0001\u0003\u0000\u0000\u0000\u0002\u0000\u0000\u0000\t\u0000\u0000\u0000H\b\u0000\u0000\u0001\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0019\u0000\u0000\u0000H\u0000\u0000\u0000__PAGEZERO\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000")
      temp_file.close
      expect(@v.send(:is_wrapper?, temp_file.path)).to be false
    end

    it "raises an error when the file does not exist" do
      expect { @v.send(:is_wrapper?, "/nonexistant/file") }.to raise_error(Errno::ENOENT)
    end
  end

  describe "#windows?" do
    it "returns true on windows" do
      stub_const("RUBY_PLATFORM", "i386-mingw32")
      expect(@v.send(:windows?)).to be true
    end

    it "returns false on linux" do
      stub_const("RUBY_PLATFORM", "x86_64-linux")
      expect(@v.send(:windows?)).to be false
    end
  end
end

describe "bin/vagrant" do
  # 'vagrant -v' => 'Vagrant 1.7.0'
  # earlier versions included the word version in their output
  let(:version_regex) { Regexp.new('^Vagrant (version)?') }
  let(:vagrant_bin) { "ruby #{Dir.getwd}/bin/vagrant" }

  it "returns usage" do
    expect(%x{#{vagrant_bin}}).to match(/^Usage/)
  end

  context "-v" do
    it "returns the full version string" do
      expect(%x{#{vagrant_bin} -v}).to match(version_regex)
    end
  end

  context "with good min-ver" do
    it "returns the full version string" do
      expect(%x{#{vagrant_bin} --min-ver=1.0 -v}).to match(version_regex)
      expect(%x{#{vagrant_bin} -v --min-ver=1.0}).to match(version_regex)
    end
  end

  context "with bad min-ver" do
    it "prints the instructions" do
      expect(%x{#{vagrant_bin} --min-ver=4.0 -v 2>&1}).to match /instructions/
    end
  end
end
