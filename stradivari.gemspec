lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'stradivari/version'

Gem::Specification.new do |spec|
  spec.name          = 'stradivari'
  spec.version       = Stradivari::VERSION
  spec.authors       = ['Lleïr Borràs Metje', 'Marcello Barnaba', 'Ivan Turkovic']
  spec.email         = ['l.borrasmetje@ifad.org', 'm.barnaba@ifad.org', 'i.turkovic@ifad.org']
  spec.summary       = 'Enterprise toolkit for Rails web apps'
  spec.description   = '
This Gem combines Rails view helpers and Stradivari-owned BEM classes to provide easy generators for:

- HTML Tables
- CSV Tables
- XLS Tables
- Tabbed layouts
- Definition Lists
- Filter forms

The shipped stylesheet is plain CSS generated from Tailwind CSS and does not require Bootstrap or Tailwind in host applications.
  '
  spec.homepage      = 'https://github.com/ifad/stradivari'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.2'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/ifad/stradivari/issues',
    'homepage_uri' => 'https://github.com/ifad/stradivari',
    'source_code_uri' => 'https://github.com/ifad/stradivari',
    'rubygems_mfa_required' => 'true'
  }

  spec.add_development_dependency 'rake'

  spec.add_dependency 'caxlsx'
  spec.add_dependency 'pg_search'
  spec.add_dependency 'ransack'
end
