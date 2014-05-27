# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'table/version'

Gem::Specification.new do |spec|
  spec.name          = "table"
  spec.version       = Table::VERSION
  spec.authors       = ["Lleïr Borràs Metje", "Marcello Barnaba", "Ivan Turkovic"]
  spec.email         = ["l.borrasmetje@ifad.org", "m.barnaba@ifad.org", "i.turkovic@ifad.org"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "https://github.com/ifad/table"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency 'pg_search'
  spec.add_runtime_dependency 'ransack'
end
