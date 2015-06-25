module Stradivari
  module Filter

    module Model
      autoload :Rails3, 'stradivari/filter/model/rails3'
      autoload :Rails4, 'stradivari/filter/model/rails4'
      autoload :ScopeSearch, 'stradivari/filter/model/scope_search'
    end

  end
end
