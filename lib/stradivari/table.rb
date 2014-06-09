require 'pg_search'
require 'ransack'

module Stradivari::Table
  autoload :Builder,   'stradivari/table/builder'
  autoload :Generator, 'stradivari/table/generator'

  module Models
    autoload :ScopeSearch, 'stradivari/table/models/scope_search'
  end
end
