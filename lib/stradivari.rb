require 'stradivari/version'
require 'stradivari/engine'

require 'stradivari/details'
require 'stradivari/filter'
require 'stradivari/tabs'
require 'stradivari/table'
require 'stradivari/csv'

module Stradivari

  autoload :Builder,    'stradivari/builder'
  autoload :Generator,  'stradivari/generator'
  autoload :Helpers,    'stradivari/helpers'
  autoload :Controller, 'stradivari/controller'

  autoload :XLSX,       'stradivari/xlsx'

  module Concerns
    autoload :TableBuilder, 'stradivari/concerns/table_builder'
  end

end
