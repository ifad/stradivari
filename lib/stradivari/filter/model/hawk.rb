module Stradivari
  module Filter
    module Model

      module Hawk
        def self.included(base)
          base.module_eval do
            include Base
            extend ClassMethods
          end
        end

        module ClassMethods
          def stradivari_type(column_name)
            ::Hawk::Model::Base.schema_type_of(column_name)
          end

          def stradivari_filter(stradivari_filter_options)
            filter = self
            params = stradivari_filter_options.deep_dup
            sort, dir = nil, nil
            params = params.delete_if do |k,v|
              delete_param = true
              if v.blank?
                # ignore blanks
              elsif k.to_sym == :sort
                sort = v
              elsif k.to_sym == :direction
                dir = v
              elsif (scope = self.stradivari_scopes.fetch(k.to_sym, nil))
                # if we have a stradivari scope, use it
                value = scope[:type] == :boolean ? v == 'true' : v
                filter = filter.public_send(k, value)
              else
                # this'll be a good where condition
                delete_param = false
              end
              delete_param
            end
            filter = filter.where(params)
            if sort.present?
              filter = filter.order("#{sort} #{dir || 'asc'}")
            end
            filter
          end
        end
      end

    end
  end
end
