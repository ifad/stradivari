# frozen_string_literal: true

module Stradivari
  module Filter
    module Helpers
      def self.radios_for_collection(collection, attr, opts)
        lambda do
          haml_tag :div do
            any_checked = true

            collection.each do |title, value|
              checked = (opts[:value].to_s == value.to_s || opts[:default_checked].to_s == value.to_s)
              any_checked = false if checked

              haml_tag :label, class: Helpers.prepare_radio_class(checked, 'radio custom-control custom-radio custom-control-inline') do
                haml_concat radio_button(opts[:namespace], attr, value, checked: checked, class: 'custom-control-input')
                haml_tag :span, title, class: 'custom-control-label custom-control-label--stradivari'
              end
            end

            if opts.fetch(:include_blank, true).to_s == 'true'
              haml_tag :label, class: Helpers.prepare_radio_class(any_checked, 'radio custom-control custom-radio custom-control-inline') do
                haml_concat radio_button(opts[:namespace], attr, '', checked: any_checked, class: 'custom-control-input')
                haml_tag :span, 'Any', class: 'custom-control-label custom-control-label--stradivari'
              end
            end
          end
        end
      end

      def self.render_title(name, title, opts)
        lambda do
          html_options = { class: 'stradivari-label' }

          if (Builder.priority(opts) == :low && !opts[:active_field]) || (opts[:active_field] && opts.fetch(:collapsed_field, false))
            title = content_tag(:span, title, class: 'text')

            title << ' ' << capture_haml do
              haml_tag :a, (opts[:active_field] ? 'Add More' : 'Expand'), href: '#', data: { toggle: 'collapse' }, role: 'button', aria: { expanded: 'false', controls: '' }, class: 'stradivari-handle'
            end

            html_options[:class] = "#{html_options[:class]} stradivari-label--expandable"
          end

          html_options[:data] = { stradivari: 'autocomplete' } if opts[:autocomplete].present?
          haml_concat(label(opts[:namespace], name, title.html_safe, html_options))
        end
      end

      def self.prepare_radio_class(active_field, default = '')
        default = default.dup
        default << ' checked' if active_field
        default
      end
    end
  end
end
