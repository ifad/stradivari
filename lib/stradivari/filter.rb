module Stradivari::Filter

  NAMESPACE              = :q
  CONTEXT                = :context
  TYPEAHEAD_DISPLAY_NAME = :name
  TYPEAHEAD_VALUE_NAME   = :id

  autoload :Generator, 'stradivari/filter/generator'
  autoload :Builder,   'stradivari/filter/builder'
  autoload :Model,     'stradivari/filter/model'

end
