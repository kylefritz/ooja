# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ooja/version"

Gem::Specification.new do |s|
  s.name        = "ooja"
  s.version     = Ooja::VERSION
  s.authors     = ["Kyle Fritz"]
  s.email       = ["kyle.p.fritz@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{turn your mac into a twitter controlled jukebox}
  s.description = %q{play songs on your mac by tweeting them on twitter}

  s.rubyforge_project = "ooja"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"

  #runtime dependencies
  s.add_runtime_dependency 'nokogiri'
  s.add_runtime_dependency  'json'
  s.add_runtime_dependency  'oauth'
end
