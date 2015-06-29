require 'pg_search'
require 'ransack'

module Stradivari
  module Filter
    module Model

      module ScopeSearch
        def self.included(base)
          base.module_eval do
            include PgSearch
            extend ClassMethods
          end
        end

        module ClassMethods
          def stradivari_filter_options(options)
            @_stradivari_filter_options = options
            @_stradivari_filter_options
          end
          alias configure_scope_search stradivari_filter_options

          ##
          # Copy search options and scopes registry on inheritance
          #
          def inherited(subclass)
            super

            subclass.stradivari_filter_options(
              self.stradivari_filter_options
            )

            subclass.stradivari_scopes.update(
              self.stradivari_scopes
            )
          end

          ##
          # Defines a search scope, callable from the query string.
          #
          def stradivari_scope(name, options = { }, &block)
            if options[:type] == :full_text
              full_text_search name, options, &block
            else
              scope name, block
            end

            stradivari_scopes.store(name, options)
          end
          alias scope_search stradivari_scope

          ##
          #
          def stradivari_scopes
            @_stradivari_scopes ||= {}
          end

          ##
          # Runs a Stradivari search on the given filter options hash.
          #
          def stradivari_filter(stradivari_filter_options)
            params = stradivari_filter_options.deep_dup
            arel = self.stradivari_all
            sort, dir = params.values_at(:sort, :direction)

            # Process search scopes
            ransack_params = params.delete_if do |k, v|
              if v.blank?
                true # Don't bother processing blank values

              elsif (scope = stradivari_scopes.fetch(k, nil))
                # Process it through a named scope
                value = scope.type == :boolean ? v == 'true' : v
                arel = arel.public_send(scope.name, value)

              else
                false # Bring it on
              end
            end

            # Process ransack, and remove eventual sorting added
            # by previously invoked named scopes. It is useful to
            # have sorting in some scopes, but when searching
            # through ransack we want always to have full control
            # on the order clause.
            if sort.present?
              ransack = arel.except(:order).ransack(ransack_params)

              arel_sort = ['sort_by', sort, dir].join('_')
              if arel.respond_to?(arel_sort) # Named scope
                ransack.result.public_send(arel_sort)

              else # Try ransack sort
                ransack.sorts = [sort, dir].join(' ')
                ransack.result
              end
            else
              # If sorting is disabled, leave arel alone, using any
              # sorting introduced by called named scopes. This is
              # useful, e.g., with pg_search's scopes, to rank search
              # results by relevance.
              arel.ransack(ransack_params).result
            end
          end
          alias extended_search stradivari_filter

          private
            def full_text_search(name, options, &block)
              dictionary = options[:dictionary] || stradivari_search_options.fetch(:dictionary, :english)
              column     = options[:column]     || stradivari_search_options.fetch(:column, 'tsv')

              # Set up pg search
              #
              pg_search_scope "#{name}_search",
                against: :unused, # Only tsvector columns allowed
                using: { tsearch: { prefix: true, dictionary: dictionary, tsvector_column: column } }

              # Create a class method accepting an additional set of options,
              # wrapping the pg_search scope. This enables the `:no_rank`
              # option that disables ranking, and just does the filtering
              # on the tsvector column.
              #
              # If a block is passed, then call it passing the original query
              # and the resulting search scope - allowing customization of
              # results.
              define_singleton_method(name) do |query, options = {}, &block|
                search = public_send("#{name}_search", query)

                search = where(search.where_values) if options[:no_rank]
                search = block.call(query, search)  if block

                search
              end
            end
        end
      end

    end
  end
end
