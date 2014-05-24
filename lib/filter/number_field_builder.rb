module Filter
  class NumberFieldBuilder < Filter::BaseFieldBuilder
    def render object_class, attribute_name, options = {}
      value = options[:value].last

      select_options = [
        ['Greater Than', "#{attribute_name}_gt"],
        ['Equal To', "#{attribute_name}_eq"],
        ['Less Than', "#{attribute_name}_lt"]
      ]

      haml_tag :div, class: "form-group" do
        haml_concat label(@@form_namespace, "#{attribute_name}_eq", options[:title] || attribute_name.to_s.humanize)
        haml_tag :div, class: "input-number" do
          haml_concat select(nil, nil, options_for_select(select_options, selected: options[:value].first), {}, class: 'form-control')
          haml_concat text_field(@@form_namespace, options[:value].first, value: value, class: 'form-control')
        end
      end
    end
  end
end
