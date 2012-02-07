$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_mt_object/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_mt_object"
  s.version     = ActsAsMtObject::VERSION
  s.authors     = ["Taku AMANO"]
  s.email       = ["taku@toi-planning.net"]
  s.homepage    = "https://github.com/usualoma/acts_as_mt_object"
  s.summary     = "Acts as Movable Type's object."
  s.description = "The active record's adapter to the database created by Movable Type"

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extra_rdoc_files = ['README.rdoc']
  s.require_paths = ['lib']

  s.test_files = Dir["test/**/*"]

  s.add_development_dependency "rails", "~> 3.1.3"
  s.add_dependency "mysql2"
end
