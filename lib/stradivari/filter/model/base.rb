# frozen_string_literal: true

module Stradivari
  module Filter
    module Model
      module Base
        def self.included(base)
          base.module_eval do
            extend ClassMethods
          end
        end

        module ClassMethods
          def stradivari_filter_options(options = nil)
            @stradivari_filter_options ||= options || {}
          end

          def configure_scope_search(*args)
            warn "#{name}.configure_scope_search is deprecated. Please use .stradivari_filter_options (called from #{caller(1..1).first})"
            stradivari_filter_options(*args)
          end

          ##
          # Copy search options and scopes registry on inheritance
          #
          def inherited(subclass)
            super

            subclass.stradivari_filter_options(
              stradivari_filter_options
            )

            subclass.stradivari_scopes.update(
              stradivari_scopes
            )
          end

          ##
          # Defines a search scope, callable from the query string.
          #
          def stradivari_scope(name, *args, &block)
            callable, options = stradivari_scope_options(*args, &block)

            scope(name, callable)
            options[:type] ||= :string
            stradivari_scopes.store(name.to_sym, options)
          end

          def scope_search(*args, &block)
            warn "#{name}.scope_search is deprecated. Please use .stradivari_scope (called from #{caller(1..1).first})"
            stradivari_scope(*args, &block)
          end

          def stradivari_scope_options(*args, &block)
            options  = args.extract_options!
            callable = args.first

            raise Stradivari::Error, "Can't give a block both via parameter and syntax" if callable && block

            [callable || block, options]
          end
          private :stradivari_scope_options

          ##
          # Keeps the registry of defined stradivari scopes
          #
          def stradivari_scopes
            @stradivari_scopes ||= {}
          end

          ##
          # Returns the normalized type for the given column name
          #
          def stradivari_type(column_name)
            raise NotImplementedError
          end

          ##
          # Runs a Stradivari search on the given filter options hash.
          #
          def stradivari_filter(stradivari_filter_options)
            raise NotImplementedError
          end

          def extended_search(*args)
            warn "#{name}.extended_search is deprecated. Please use .stradivari_filter (called from #{caller(1..1).first})"
            stradivari_filter(*args)
          end
        end
      end
    end
  end
end
