# frozen_string_literal: true

module Stradivari
  module Filter
    class Builder::DateRangeField < Builder
      def self.render
        lambda do |attr, opts|
          from_value = opts[:value].first
          to_value   = opts[:value].last

          haml_tag :div, class: "form-group form-group--stradivari #{opts[:form_group_class]}", data: { stradivari: { attr: attr } } do
            instance_exec(&Helpers.render_title(attr, opts.fetch(:title, attr.to_s.humanize), opts))

            haml_tag :div, class: Builder.prepare_classes(opts) do
              haml_tag :div, class: 'd-flex justify-content-center mb-2' do
                haml_concat instance_exec(&Helpers.renderable_field(attr, from_value, opts, 'gteq'))
                haml_tag :span, '-', class: 'align-self-center px-2'
                haml_concat instance_exec(&Helpers.renderable_field(attr, from_value, opts, 'lteq'))
              end
            end
          end
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
