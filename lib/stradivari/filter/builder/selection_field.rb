require 'stradivari/filter/helpers'

module Stradivari
  module Filter
    class Builder::SelectionField < Builder
      def self.render
        lambda do |attr, opts|
          collection = opts[:collection].is_a?(Proc) ? opts[:collection].call : opts[:collection]
          title      = opts.fetch(:title, attr.to_s.humanize)
          attr       = [attr, 'eq'].join('_') unless opts[:is_scoped]

          radios_max = opts.fetch(:radios_count, 5)

          opts[:collapsed_field] = true if (opts[:value].present? & collection.is_a?(Array)) && collection.size <= radios_max

          field = content_tag(:div, class: Builder.prepare_classes(opts)) do
            if collection.is_a?(Array) && collection.size <= radios_max
              capture { instance_exec(&Helpers.radios_for_collection(collection, attr, opts)) }
            else
              select(opts[:namespace], attr, collection, { selected: opts[:value], include_blank: 'Any' }, { class: 'form-control' })
            end
          end

          concat content_tag(:div, safe_join([
                                               capture { instance_exec(&Helpers.render_title(attr, title, opts)) },
                                               field
                                             ]), class: 'form-group')
        end
      end
    end
  end
end
