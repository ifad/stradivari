module Stradivari
  module Table
    module Model

      module ActiveRecord
        def self.included(base)
          base.module_eval do
            # Add agnostic module API
            include Base
            extend ClassMethods
          end
        end

        module ClassMethods
          def sortable_by? sort_key
            super ||
            self.column_names.include?(sort_key) ||
            self.reflections.keys.any? { |related| sort_key.include?(related.to_s) }
          end
        end
      end

    end
  end
end
