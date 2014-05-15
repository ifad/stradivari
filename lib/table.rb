require 'table/version'
require 'table/engine'
require 'filter'

module Table
  autoload :ActionBuilder,   'table/action_builder'
  autoload :BaseBuilder,     'table/base_builder'
  autoload :BooleanBuilder,  'table/boolean_builder'
  autoload :CheckboxBuilder, 'table/checkbox_builder'
  autoload :Column,          'table/column'
  autoload :DateBuilder,     'table/date_builder'
  autoload :FileBuilder,     'table/file_builder'
  autoload :Generator,       'table/generator'
  autoload :NumberBuilder,   'table/number_builder'
  autoload :TextBuilder,     'table/text_builder'
  autoload :TextLinkBuilder, 'table/text_link_builder'

  module Models
    autoload :ScopeSearch, 'table/models/scope_search'
  end
end
