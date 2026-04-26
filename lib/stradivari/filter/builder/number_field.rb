module Stradivari
  module Filter
    class Builder::NumberField < Builder
      def self.render
        lambda do |attr, opts|
          value = opts[:value].last

          select_opts = [
            ['Greater Than', "#{attr}_gt"],
            ['Equal To', "#{attr}_eq"],
            ['Less Than', "#{attr}_lt"]
          ]

          attributes = Builder.control_attributes(opts, 'stradivari-filter__number')
          attributes[:data] = (attributes[:data] || {}).merge(stradivari_filter_field: 'number')

          fields = content_tag(:div, attributes) do
            safe_join([
                        select(nil, nil, options_for_select(select_opts, selected: opts[:value].first), {}, class: 'stradivari-control'),
                        text_field(opts[:namespace], opts[:value].first, value: value, class: 'stradivari-control')
                      ])
          end

          concat content_tag(:div, safe_join([
                                               capture { instance_exec(&Helpers.render_title("#{attr}_eq", opts[:title] || attr.to_s.humanize, opts)) },
                                               fields
                                             ]), Builder.field_attributes(opts))
        end
      end

      def self.value(params, name)
        if params["#{name}_lt"].present?
          ["#{name}_lt", params["#{name}_lt"]]

        elsif params["#{name}_gt"].present?
          ["#{name}_gt", params["#{name}_gt"]]

        else
          ["#{name}_eq", params["#{name}_eq"]]

        end
      end

      def self.active?(params, name)
        !![params["#{name}_eq"], params["#{name}_lt"], params["#{name}_gt"]].find(&:present?)
      end
    end
  end
end
