require 'active_support/concern'
require 'pg_search'
require 'ransack'

module Stradivari
  module Filter
    module Model

      module ScopeSearch
        extend ActiveSupport::Concern

        included do
          include PgSearch
        end

        module ClassMethods
          def scope_search_dictionary=(d)
            @_scope_search_dictionary = d
          end

          def scope_search(name, options = { }, &block)
            if options[:type] == :full_text
              options[:type] = :string
              full_text_search(name, options, &block)
            else
              scope name, block
            end

            if options[:type] == :boolean
              options.merge!(:validator => lambda { |val| [ true, false ].include?(val) })
            end

            ransacker name, options
          end

          private
            def full_text_search(name, options, &block)
              # Set up pg search
              #
              pg_search_scope "#{name}_search",
                :against => :unused, # Only tsvector columns allowed
                :using => {
                  :tsearch => {
                    :prefix => true,
                    :dictionary => options[:dictionary] || @_scope_search_dictionary || :english,
                    :tsvector_column => 'tsv'
                  }
                }

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

        module Extensions
          def configure_scope_search options = {}
            include Stradivari::Filter::Model::ScopeSearch

            self.scope_search_dictionary = options[:dictionary] || :english
          end
          #
          # Method to search for expressions beyond ransack
          #
          def stradivari_filter(stradivari_filter_options)
            params = stradivari_filter_options.deep_dup
            arel = self.stradivari_all
            sort, dir = params.values_at(:sort, :direction)

            # Process search scopes
            ransack_params = params.delete_if do |k, v|
              if v.blank?
                true # Don't bother processing blank values

              elsif (scope = arel._ransackers[k])
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
        end
      end

    end
  end
end
