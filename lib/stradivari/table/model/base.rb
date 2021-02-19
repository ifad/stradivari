# frozen_string_literal: true

module Stradivari
  module Table
    module Model
      module Base
        def self.included(base)
          base.module_eval do
            extend ClassMethods
          end
        end

        module ClassMethods
          def sortable_by?(sort_key)
            stradivari_scopes[sort_key.to_sym].present? ||
              respond_to?(['sort_by', sort_key, 'asc'].join('_'))
          end
        end
      end
    end
  end
end
