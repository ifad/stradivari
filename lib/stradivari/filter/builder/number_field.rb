# frozen_string_literal: true

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

          haml_tag :div, class: 'form-group form-group--stradivari' do
            instance_exec(&Helpers.render_title("#{attr}_eq", opts[:title] || attr.to_s.humanize, opts))

            haml_tag :div, class: Builder.prepare_classes(opts) do
              haml_tag :div, class: 'd-flex justify-content-center mb-2' do
                haml_concat select(nil, nil, options_for_select(select_opts, selected: opts[:value].first), {}, class: 'custom-select')
                haml_concat text_field(opts[:namespace], opts[:value].first, value: value, class: 'form-control ml-2')
              end
            end
          end
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
