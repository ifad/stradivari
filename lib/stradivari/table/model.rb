# frozen_string_literal: true

module Stradivari
  module Table
    module Model
      autoload :Base,         'stradivari/table/model/base'
      autoload :ActiveRecord, 'stradivari/table/model/active_record'
      autoload :Hawk,         'stradivari/table/model/hawk'
    end
  end
end
