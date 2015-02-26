# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "trivial_sso/version"

Gem::Specification.new do |s|
  s.name     = "trivial_sso"
  s.version  = TrivialSso::VERSION
  s.platform = Gem::Platform::RUBY

  s.authors     = ["David J. Lee","David Southard"]
  s.email       = ["david@lee.dj","nacengineer@gmail.com"]
  s.homepage    = "https://github.com/nacengineer/trivial_sso"
  s.summary     = "A simple library to help with Single Sign On cookies"
  s.description = "Used to encode and decode cookies used in a single
                   sign on implementation within the same domain"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.files   = Dir.glob("{bin,lib}/**/*") + %w(MIT-LICENSE README.md CHANGELOG.md)
  s.license = 'MIT'
  s.required_ruby_version = '>= 1.9.3'
  s.require_paths         = ["lib"]

  s.add_runtime_dependency 'rails', '~> 4.2.0', '>= 4.2.0'
  s.add_runtime_dependency 'activesupport', '~> 4.2', '>= 4.2'
end
