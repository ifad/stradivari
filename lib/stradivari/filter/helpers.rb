module Stradivari
  module Filter
    module Helpers

      def self.radios_for_collection(collection, attr, opts)
        lambda do
          haml_tag :div, class: 'form-inline' do
            any_checked = true


            collection.each do |title, value|
              checked = (opts[:value].to_s == value.to_s)
              any_checked = false if checked

              haml_tag :div, class: Helpers::prepare_radio_class(checked, 'radio') do
                haml_tag :label do
                  haml_concat radio_button(opts[:namespace], attr, value, checked: checked)
                  haml_concat title
                end
              end
            end

            haml_tag :div, class: Helpers::prepare_radio_class(any_checked, 'radio') do
              haml_tag :label do
                haml_concat radio_button(opts[:namespace], attr, '', checked: any_checked)
                haml_concat 'Any'
              end
            end
          end
        end
      end

      def self.render_title(name, title, opts)
        lambda do
          if (Builder::priority(opts) == :low && !opts[:active_field]) ||
             (opts[:active_field] && opts.fetch(:collapsed_field, false))
            title = content_tag(:span, title, class: "text")

            title << ' ' << capture_haml do
              haml_tag :span, (opts[:active_field] ? 'Add More' : 'Expand'), class: 'handle'
            end
          end
          data = {data: {stradivari: "autocomplete"}} if opts[:autocomplete].present?
          haml_concat(label(opts[:namespace], name, title.html_safe, data))
        end
      end

      def self.prepare_radio_class(active_field, default = '')
        default << " checked" if active_field
        default
      end

    end
  end
end
