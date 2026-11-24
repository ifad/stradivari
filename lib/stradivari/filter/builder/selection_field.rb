require 'stradivari/filter/helpers'

module Stradivari
  module Filter
    class Builder::SelectionField < Builder
      def self.render
        lambda do |attr, opts|
          collection = opts[:collection].is_a?(Proc) ? opts[:collection].call : opts[:collection]
          title      = opts.fetch(:title, attr.to_s.humanize)
          multiple   = opts.fetch(:multiple, false).to_s == 'true'
          attr       = [attr, (multiple ? 'in' : 'eq')].join('_') unless opts[:is_scoped]

          collection = collection.map { |item| [item, item] } if collection.is_a?(Array) && collection.first.present? && !collection.first.is_a?(Array)

          radios_max = opts.fetch(:radios_count, 5)
          radios     = !multiple && collection.is_a?(Array) && collection.size <= radios_max

          opts[:collapsed_field] = true if opts[:value].present? && radios

          field = content_tag(:div, Builder.control_attributes(opts)) do
            if radios
              capture { instance_exec(&Helpers.radios_for_collection(collection, attr, opts)) }
            else
              select_options = { selected: opts[:value] }
              select_options[:include_blank] = 'Any' if opts.fetch(:include_blank, true).to_s == 'true'

              html_options = { class: Stradivari::ClassNames.join('stradivari-control', opts[:class]) }
              html_options[:multiple] = 'multiple' if multiple

              select(opts[:namespace], attr, collection, select_options, html_options)
            end
          end

          concat content_tag(:div, safe_join([
                                               capture { instance_exec(&Helpers.render_title(attr, title, opts)) },
                                               field
                                             ]), Builder.field_attributes(opts))
        end
      end
    end
  end
end
