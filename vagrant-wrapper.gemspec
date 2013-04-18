Gem::Specification.new do |s|
  s.name        = 'vagrant-wrapper'
  s.version     = '1.2.0'
  s.date        = '2013-04-18'

  s.summary     = "Wrapper/binstub for os packaged version of Vagrant."
  s.description = <<-DESC
Given Vagrant 1.1+ is distributed only via packaged installers, this Gem provides
a wrapper such-that an existing Gem install of the older Vagrant will not take
precedence on the command line in a bundled project. Eg. shell calls to 'vagrant'
will use the packaged version.

(NOTE: The version of the Gem does not determine the version of Vagrant it links to.)
  DESC

  s.licenses    = ['MIT']
  s.authors     = ["BinaryBabel OSS"]
  s.email       = ["projects@binarybabel.org"]
  s.homepage    = "http://code.binbab.org"

  s.files       = ["lib/vagrant-wrapper.rb"]
  s.executables = ["vagrant"]
end
