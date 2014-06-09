require 'stradivari/version'
require 'stradivari/engine'

require 'details'
require 'filter'
require 'tabs'
require 'table'

module Stradivari

  autoload :Generator,  'stradivari/generator'
  autoload :Helpers,    'stradivari/helpers'
  autoload :Controller, 'stradivari/controller'

  module Concerns
    autoload :TableBuilder, 'stradivari/concerns/table_builder'
  end

end
