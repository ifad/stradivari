require 'stradivari/filter/helpers'

module Stradivari
  module Filter
    class Builder::BooleanField < Builder
      def self.render
        lambda do |attr, opts|
          title = opts.fetch(:title, attr.to_s.humanize)
          attr  = [attr, 'eq'].join('_') unless opts[:is_scoped]

          opts[:collapsed_field] = true if opts[:value].present?

          body = if opts.fetch(:tristate, false)
                   safe_join([
                               capture { instance_exec(&Helpers.render_title(attr, title, opts)) },
                               content_tag(:div, capture do
                                 instance_exec(&Helpers.radios_for_collection([%w[Yes true], %w[No false]], attr, opts))
                               end, Builder.control_attributes(opts))
                             ])
                 else
                   content_tag(:div, class: 'stradivari-filter__choice stradivari-filter__choice--checkbox stradivari-filter__choice--single', data: { stradivari_filter_choice: true }) do
                     content_tag(:label, safe_join([
                                                     title,
                                                     check_box(opts[:namespace], attr, { checked: opts[:value].present? }, 'true', nil)
                                                   ]))
                   end
                 end

          concat content_tag(:div, body, Builder.field_attributes(opts))
        end
      end
    end
  end
end
