module Stradivari
  module Filter
    module Helpers

      def self.radios_for_collection(collection, attr, opts)
        lambda do
          haml_tag :div, class: 'form-inline' do
            any_checked = true

            collection.each do |title, value|
              haml_tag :div, class: 'radio' do
                checked = (opts[:value].to_s == value.to_s)
                any_checked = false if checked

                haml_tag :label do
                  haml_concat radio_button(opts[:namespace], attr, value, checked: checked)
                  haml_concat title
                end
              end
            end

            haml_tag :div, class: 'radio' do
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
          if Builder::priority(opts) == :low && !opts[:active_field]
            title << ' ' << capture_haml do
              haml_tag :span, 'show', class: 'presentable'
            end
          end

          haml_concat(label opts[:namespace], name, title.html_safe)
        end
      end

    end
  end
end
