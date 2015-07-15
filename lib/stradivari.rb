require 'stradivari/version'
require 'stradivari/engine'

module Stradivari

  autoload :Error,      'stradivari/error'

  autoload :Builder,    'stradivari/builder'
  autoload :Generator,  'stradivari/generator'
  autoload :Helpers,    'stradivari/helpers'
  autoload :Controller, 'stradivari/controller'

  autoload :Details,    'stradivari/details'
  autoload :Table,      'stradivari/table'
  autoload :Tabs,       'stradivari/tabs'
  autoload :Filter,     'stradivari/filter'

  autoload :CSV,        'stradivari/csv'
  autoload :XLSX,       'stradivari/xlsx'

  module Concerns
    autoload :TableBuilder, 'stradivari/concerns/table_builder'
  end

end
