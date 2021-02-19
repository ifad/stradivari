# frozen_string_literal: true

module Stradivari
  module Filter
    module Model
      autoload :Base,         'stradivari/filter/model/base'
      autoload :ActiveRecord, 'stradivari/filter/model/active_record'
      autoload :Rails,        'stradivari/filter/model/rails'
      autoload :Hawk,         'stradivari/filter/model/hawk'
    end
  end
end
