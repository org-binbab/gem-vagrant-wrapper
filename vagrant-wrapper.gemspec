Gem::Specification.new do |s|
  s.name        = 'vagrant-wrapper'
  s.version     = '1.2.1'
  s.date        = '2013-05-02'

  s.summary     = "Wrapper/binstub for os packaged version of Vagrant."
  s.description = <<-DESC
Since Vagrant 1.1+ is no longer distributed via Gems, vagrant-wrapper allows you to require and interact
with the newer package versions via your Gemfile, shell, or Ruby code. It allows the newer packaged
version to take precedence even if the older Vagrant gem remains installed.
See https://github.com/org-binbab/gem-vagrant-wrapper for more details.
  DESC

  s.licenses    = ['MIT']
  s.authors     = ["BinaryBabel OSS"]
  s.email       = ["projects@binarybabel.org"]
  s.homepage    = "http://code.binbab.org"

  s.add_development_dependency "rspec"
  s.add_development_dependency "vagrant", "1.0.7"

  s.bindir        = "bin"
  s.executables   = %w{ vagrant }

  s.require_path  = "lib"
  s.files         = %w{ LICENSE README.md } + Dir.glob("{lib}/**/*")
end
