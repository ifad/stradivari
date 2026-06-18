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
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # No required_ruby_version cap: consumers span Ruby 2.x (pre-upgrade) through
  # 4.0; the gem code runs on all of them. CI sweeps the supported matrix.

  spec.add_development_dependency "rake"

  # Runtime deps test through Rails 8.1 (see Appraisals / CI). haml >= 6 is
  # supported via Stradivari::HamlCompat (haml_tag/haml_concat/capture_haml).
  spec.add_runtime_dependency 'pg_search'
  spec.add_runtime_dependency 'ransack'
  spec.add_runtime_dependency 'haml'
  spec.add_runtime_dependency 'caxlsx'
end
