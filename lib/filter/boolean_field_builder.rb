module Filter
  class BooleanFieldBuilder < Filter::BaseFieldBuilder
    def render object_class, attribute_name, options = {}
      value = options[:value]

      name = "#{attribute_name}_eq"

      haml_tag :div, class: "form-group" do
        if options[:attribute_type] == :ransack
          haml_concat label(@@form_namespace, attribute_name, options[:title] || attribute_name.to_s.humanize)
          haml_concat select(@@form_namespace, attribute_name, [['Yes', 'true'], ['No', 'false']], {include_blank: 'Any', selected: value}, {class: 'form-control'})
        elsif options[:attribute_override_type] == :ransack
          haml_concat label(@@form_namespace, name, options[:title] || attribute_name.to_s.humanize)
          haml_concat select(@@form_namespace, name, [['Yes', 'true'], ['No', 'false']], {include_blank: 'Any', selected: value}, {class: 'form-control'})
        else
          haml_tag :div, class: 'checkbox' do
            haml_tag :label do
              haml_concat check_box(@@form_namespace, name, {checked: value.present?}, 'true', nil)
              haml_tag :b, options[:title] || attribute_name.to_s.humanize
            end
          end
        end
      end
    end
  end
end
