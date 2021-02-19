# frozen_string_literal: true

module Stradivari
  module Table
    module Model
      module Hawk
        def self.included(base)
          base.module_eval do
            include Base
            extend ClassMethods
          end
        end

        module ClassMethods
          def sortable_by?(_sort_key)
            # Hawk does not give us any sorting information, but should accept
            # the sort request regardless
            true
          end
        end
      end
    end
  end
end
