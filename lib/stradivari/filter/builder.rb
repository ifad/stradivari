module Stradivari
  module Filter
    class Builder < Stradivari::Builder
      Implementations = {
        selection: 'SelectionField',
        date_range: 'DateRangeField',
        number: 'NumberField',
        boolean: 'BooleanField',
        checkbox: 'CheckboxField',
        search: 'SearchField',
        custom: 'CustomField'
      }.each_with_object({}) do |(id, name), memo|
        require "stradivari/filter/builder/#{id}_field"
        memo[id] = const_get(name)
      end.freeze

      autoload :ActionField, 'stradivari/filter/builder/action_field'

      class << self
        CONTROL_CLASS = 'stradivari-filter__control'.freeze
        FIELD_CLASS = 'stradivari-filter__field'.freeze

        def value(params, name)
          params[name] || params["#{name}_eq"]
        end

        def active?(params, name)
          value(params, name).present?
        end

        def prepare_classes(opts, classes = '')
          class_list = classes.to_s.split
          class_list << CONTROL_CLASS if class_list.empty?

          base_class = class_list.first

          Stradivari::ClassNames.join(
            class_list,
            Stradivari::ClassNames.modifier(base_class, "priority-#{priority(opts)}"),
            Stradivari::ClassNames.modifier(base_class, :closed, enabled: collapsed?(opts))
          )
        end

        def control_attributes(opts, classes = '')
          attributes = { class: prepare_classes(opts, classes) }
          attributes[:data] = { stradivari_filter_collapsible: true } if collapsed?(opts)
          attributes
        end

        def field_attributes(opts = {})
          {
            class: Stradivari::ClassNames.join(
              FIELD_CLASS,
              Stradivari::ClassNames.modifier(FIELD_CLASS, "priority-#{priority(opts)}")
            ),
            data: { stradivari_filter_field_wrapper: true }
          }
        end

        def priority(opts = {})
          opts.fetch :priority, :normal # :low, :normal, :high
        end

        def collapsed?(opts = {})
          priority(opts) == :low && !opts[:active_field]
        end
      end
    end
  end
end
