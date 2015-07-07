require 'pg_search'
require 'ransack'

module Stradivari
  module Filter
    module Model

      module ActiveRecord
        def self.included(base)
          base.module_eval do
            # Load the appropriate stradivari_all adapter
            #
            case (ver = ::ActiveRecord::VERSION::MAJOR)
            when 3 then extend Rails3
            when 4 then extend Rails4
            else
              raise Error, "Unsupported Active Record version (#{ver})"
            end

            # Add agnostic module API
            include Base
            extend ClassMethods

            # Add PG Full Text Search adapter
            include ::PgSearch
          end
        end

        module ClassMethods
          def stradivari_scope(name, options = {}, &block)
            if options[:type] == :full_text
              full_text_search name, options, &block
              stradivari_scopes.store(name.to_sym, options)
            else
              super
            end
          end

          def stradivari_type(column_name)
            columns_hash.fetch(column_name.to_s, nil).try(:type)
          end

          def stradivari_filter(stradivari_filter_options)
            params = stradivari_filter_options.deep_dup
            arel = self.stradivari_all
            sort, dir = params.values_at(:sort, :direction)

            # Process search scopes
            ransack_params = params.delete_if do |k, v|
              if v.blank?
                true # Don't bother processing blank values

              elsif (scope = stradivari_scopes.fetch(k.to_sym, nil))
                # Process it through a named scope
                value = scope[:type] == :boolean ? v == 'true' : v
                arel = arel.public_send(k, value)

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

          private
            def full_text_search(name, options, &block)
              dictionary = options[:dictionary] || stradivari_filter_options.fetch(:dictionary, :english)
              column     = options[:column]     || stradivari_filter_options.fetch(:column, 'tsv')

              # Set up pg search
              #
              pg_search_scope "_#{name}",
                against: :unused, # Only tsvector columns allowed
                using: { tsearch: { prefix: true, dictionary: dictionary, tsvector_column: column } }

              # Create a class method accepting an additional set of options,
              # wrapping the pg_search scope.
              #
              # If a block is passed, then call it passing the original query
              # and the resulting search scope - allowing customization of
              # results.
              define_singleton_method(name) do |query, options = {}, &block|
                search = public_send("_#{name}", query)
                search = block.call(query, search) if block

                search
              end
            end
        end
      end

    end
  end
end
