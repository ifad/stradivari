module Stradivari
  module Filter

    module Model
      autoload :Base,         'stradivari/filter/model/base'
      autoload :ActiveRecord, 'stradivari/filter/model/active_record'
      autoload :Rails3,       'stradivari/filter/model/rails3'
      autoload :Rails4,       'stradivari/filter/model/rails4'
    end

  end
end
