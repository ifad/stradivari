require 'pg_search'
require 'ransack'

module Table
  autoload :ActionBuilder,   'table/action_builder'
  autoload :BooleanBuilder,  'table/boolean_builder'
  autoload :CheckboxBuilder, 'table/checkbox_builder'
  autoload :Column,          'table/column'
  autoload :DateBuilder,     'table/date_builder'
  autoload :FileBuilder,     'table/file_builder'
  autoload :Generator,       'table/generator'
  autoload :NumberBuilder,   'table/number_builder'
  autoload :TextBuilder,     'table/text_builder'
  autoload :TextLinkBuilder, 'table/text_link_builder'

  module Controllers
    autoload :Sort,          'table/controllers/sort'
  end

  module Models
    autoload :ScopeSearch,   'table/models/scope_search'
  end
end
