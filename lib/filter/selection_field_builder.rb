module Filter
  class SelectionFieldBuilder

    def self.render
      lambda do |_, attr, opts|
        collection = opts[:collection].is_a?(Proc) ? opts[:collection].call : opts[:collection]
        title      = opts.fetch(:title, attr.to_s.humanize)
        attr       = opts[:is_scoped] ? attr : [attr, 'eq'].join('_')

        haml_tag :div, class: 'form-group' do
          haml_concat label(opts[:namespace], attr, title)

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
            haml_concat select(opts[:namespace], attr, collection, {selected: opts[:value], include_blank: 'Any'}, {class: 'form-control'})
          end
        end
      end
    end

  end
end
