module Filter
  class BooleanFieldBuilder < Filter::BaseFieldBuilder
    def render object_class, attribute_name, options = {}
      value = options[:value]

      name = "#{attribute_name}_eq"

      haml_tag :div, class: "form-group" do
        if options[:attribute_type] == :ransack
          haml_concat label("search_fields", attribute_name, options[:title] || attribute_name.to_s.humanize)
          haml_concat select(:search_fields, attribute_name, [['Yes', 'true'], ['No', 'false']], {include_blank: 'Any', selected: value}, {class: 'form-control'})
        elsif options[:attribute_override_type] == :ransack
          haml_concat label("search_fields", name, options[:title] || attribute_name.to_s.humanize)
          haml_concat select(:search_fields, name, [['Yes', 'true'], ['No', 'false']], {include_blank: 'Any', selected: value}, {class: 'form-control'})
        else
          haml_tag :div, class: 'checkbox' do
            haml_tag :label do
              haml_concat check_box(:search_fields, name, {checked: value.present?}, 'true', nil)
              haml_tag :b, options[:title] || attribute_name.to_s.humanize
            end
          end
        end
      end
    end
  end
end
