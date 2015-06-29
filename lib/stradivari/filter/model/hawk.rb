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
            params = stradivari_filter_options.dup

            where(params.delete_if {|k,v| v.blank?})
          end
        end
      end

    end
  end
end
