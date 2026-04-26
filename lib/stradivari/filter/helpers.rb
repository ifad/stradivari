module Stradivari
  module Filter
    module Helpers
      def self.radios_for_collection(collection, attr, opts)
        lambda do
          any_checked = true

          radios = collection.map do |title, value|
            checked = opts[:value].to_s == value.to_s || opts[:default_checked].to_s == value.to_s
            any_checked = false if checked
            data = { stradivari_filter_choice: true }
            data[:stradivari_state] = 'checked' if checked

            content_tag(:div, class: Helpers.prepare_radio_class(checked), data: data) do
              content_tag(:label, safe_join([
                                              radio_button(opts[:namespace], attr, value, checked: checked),
                                              title
                                            ]))
            end
          end

          if opts.fetch(:include_blank, true).to_s == 'true'
            data = { stradivari_filter_choice: true }
            data[:stradivari_state] = 'checked' if any_checked

            radios << content_tag(:div, class: Helpers.prepare_radio_class(any_checked), data: data) do
              content_tag(:label, safe_join([
                                              radio_button(opts[:namespace], attr, '', checked: any_checked),
                                              'Any'
                                            ]))
            end
          end

          concat content_tag(:div, safe_join(radios), class: 'stradivari-filter__choice-list stradivari-filter__choice-list--inline')
        end
      end

      def self.render_title(name, title, opts)
        lambda do
          if (Builder.priority(opts) == :low && !opts[:active_field]) ||
             (opts[:active_field] && opts.fetch(:collapsed_field, false))
            title = content_tag(:span, title, class: 'stradivari-filter__label-text')

            title << ' ' << capture do
              concat content_tag(:span, (opts[:active_field] ? 'Add More' : 'Expand'), class: 'stradivari-filter__toggle', data: { stradivari_filter_toggle: true })
            end
          end
          data = { data: { stradivari: 'autocomplete' } } if opts[:autocomplete].present?
          concat(label(opts[:namespace], name, title.html_safe, data))
        end
      end

      def self.prepare_radio_class(active_field, default = 'stradivari-filter__choice stradivari-filter__choice--radio')
        Stradivari::ClassNames.join(
          default,
          Stradivari::ClassNames.modifier('stradivari-filter__choice', :checked, enabled: active_field)
        )
      end
    end
  end
end
