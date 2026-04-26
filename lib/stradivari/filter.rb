module Stradivari
  module Filter
    NAMESPACE              = :q
    CONTEXT                = :context

    autoload :Generator, 'stradivari/filter/generator'
    autoload :Builder,   'stradivari/filter/builder'
    autoload :Model,     'stradivari/filter/model'
  end
end
