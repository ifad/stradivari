# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'stradivari/version'

Gem::Specification.new do |spec|
  spec.name          = "stradivari"
  spec.version       = Stradivari::VERSION
  spec.authors       = ["Lleïr Borràs Metje", "Marcello Barnaba", "Ivan Turkovic"]
  spec.email         = ["l.borrasmetje@ifad.org", "m.barnaba@ifad.org", "i.turkovic@ifad.org"]
  spec.summary       = %q{Enterprise toolkit for Ruby/HAML/Bootstrap3 web apps}
  spec.description   = %q{
This Gem combines HAML and Bootstrap 3 to provide you easy generators for:

- HTML Tables
- CSV Tables
- XLS Tables
- Tabbed layouts
- Definition Lists
- Filter forms
  }
  spec.homepage      = "https://github.com/ifad/stradivari"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rails", ">= 3.2.0"
  spec.add_development_dependency "appraisal", "~> 1.0.0"
  spec.add_development_dependency "rspec-rails", "~> 3.1"
  spec.add_development_dependency "nokogiri", "~> 1.6.0"
  spec.add_development_dependency "kaminari"
  spec.add_development_dependency "factory_girl_rails"  


  spec.add_runtime_dependency 'pg_search'
  spec.add_runtime_dependency 'ransack'
  spec.add_runtime_dependency 'haml',     [">= 3.1", "< 5.0"]
  spec.add_runtime_dependency 'axlsx'
end
