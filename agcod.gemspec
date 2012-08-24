# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "agcod/version"

Gem::Specification.new do |s|
  s.name        = "agcod"
  s.version     = Agcod::VERSION
  s.authors     = ["Dan Pickett"]
  s.email       = %q{dpickett@enlightsolutions.com}
  s.homepage    = %q{http://github.com/dpickett/agcod}
  s.summary     = %q{A Wrapper for Amazon Gift Codes On Demand}
  s.description = %q{Access the Amazon API to order gift codes}

  s.rubyforge_project = "agcod"

  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'fakeweb'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'shoulda'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
