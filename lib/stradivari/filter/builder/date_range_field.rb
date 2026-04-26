module Stradivari
  module Filter
    class Builder::DateRangeField < Builder
      def self.render
        lambda do |attr, opts|
          from_value = opts[:value].first
          to_value   = opts[:value].last

          fields = content_tag(:div, Builder.control_attributes(opts, 'stradivari-filter__date-range')) do
            safe_join([
                        text_field(opts[:namespace], "#{attr}_gteq", { value: from_value, class: 'stradivari-control' }),
                        content_tag(:span, '-', class: 'stradivari-filter__delimiter'),
                        text_field(opts[:namespace], "#{attr}_lteq", { value: to_value, class: 'stradivari-control' })
                      ])
          end

          concat content_tag(:div, safe_join([
                                               capture { instance_exec(&Helpers.render_title(attr, opts.fetch(:title, attr.to_s.humanize), opts)) },
                                               fields
                                             ]), Builder.field_attributes(opts))
        end
      end

      def self.value(params, name)
        [params["#{name}_gteq"], params["#{name}_lteq"]]
      end

      def self.active?(params, name)
        !!value(params, name).find(&:present?)
      end
    end
  end
end
