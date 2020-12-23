require 'stradivari/filter/helpers'

module Stradivari
  module Filter
    class Builder::SelectionField < Builder

      def self.render
        lambda do |attr, opts|
          collection = opts[:collection].is_a?(Proc) ? opts[:collection].call : opts[:collection]
          title      = opts.fetch(:title, attr.to_s.humanize)
          attr       = opts[:is_scoped] ? attr : [attr, 'eq'].join('_')

          radios_max = opts.fetch(:radios_count, 5)

          opts[:collapsed_field] = true if opts[:value].present? & collection.kind_of?(Array) && collection.size <= radios_max

          haml_tag :div, class: 'form-group' do
            instance_exec(&Helpers::render_title(attr, title, opts))

            haml_tag :div, class: Builder::prepare_classes(opts) do
              if collection.kind_of?(Array) && collection.size <= radios_max
                instance_exec(&Helpers.radios_for_collection(collection, attr, opts))
              else
                options = { selected: opts[:value] }
                options[:include_blank] = 'Any' if opts.fetch(:include_blank, true).to_s == 'true'

                haml_concat select(opts[:namespace], attr, collection, {selected: opts[:value], include_blank: 'Any'}, {class: 'form-control'})
              end
            end
          end
        end
      end

    end
  end
end
