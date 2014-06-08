module Filter
  class SelectionFieldBuilder
    def self.render
      lambda do |_, attr, opts|
        value      = opts[:value]
        collection = opts[:collection].is_a?(Proc) ? opts[:collection].call : opts[:collection]
        input_name = opts[:field_name].present? ? opts[:field_name] : attr
        namespace  = opts[:namespace]

        title = opts.fetch(:title, attr.to_s.humanize)
        field_name = if opts[:attribute_type] == :ransack
          input_name
        else
          "#{input_name}_eq"
        end

        haml_tag :div, class: 'form-group' do
          haml_concat label(namespace, field_name, title)

          if collection.kind_of?(Array) && collection.size <= 5
            haml_tag :div, class: 'form-inline' do
              any_checked = true

              collection.each do |t, v|
                haml_tag :div, class: 'radio' do
                  checked = (value.to_s == v.to_s)
                  any_checked = false if checked

                  haml_tag :label do
                    haml_concat radio_button(namespace, field_name, v, checked: checked)
                    haml_concat t
                  end
                end
              end

              haml_tag :div, class: 'radio' do
                haml_tag :label do
                  haml_concat radio_button(namespace, field_name, '', checked: any_checked)
                  haml_concat 'Any'
                end
              end
            end
          else
            haml_concat select(namespace, field_name, collection, {selected: value, include_blank: 'Any'}, {class: 'form-control'})
          end
        end
      end
    end
  end
end
