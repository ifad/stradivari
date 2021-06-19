# frozen_string_literal: true

require 'stradivari/filter/helpers'

module Stradivari
  module Filter
    class Builder::BooleanField < Builder
      def self.render
        lambda do |attr, opts|
          title = opts.fetch(:title, attr.to_s.humanize)
          attr  = opts[:is_scoped] ? attr : [attr, 'eq'].join('_')

          opts[:collapsed_field] = true if opts[:value].present?

          haml_tag :div, class: "form-group form-group--stradivari #{opts[:form_group_class]}", data: { stradivari: { attr: attr } } do
            if opts.fetch(:tristate, false)
              instance_exec(&Helpers.render_title(attr, title, opts))
              haml_tag :div, class: Builder.prepare_classes(opts) do
                instance_exec(&Helpers.radios_for_collection([%w[Yes true], %w[No false]], attr, opts))
              end
            else
              haml_tag :label, class: 'custom-control custom-checkbox single-value' do
                haml_concat check_box(opts[:namespace], attr,
                                      { checked: opts[:value].present?, class: 'custom-control-input' }, 'true', nil)
                haml_tag :span, title, class: 'custom-control-label custom-control-label--stradivari'
              end
            end
          end
        end
      end
    end
  end
end
