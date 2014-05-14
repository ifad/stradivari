
module Filter
  class SearchFieldBuilder < Filter::BaseFieldBuilder
    def render object_class, attribute_name, options = {}
      haml_tag :div, class: 'form-group' do
        value = options[:value]
        haml_concat label(@@form_namespace, "#{attribute_name}_cont", options[:title] || "Search #{attribute_name.to_s.humanize}")
        haml_concat text_field(@@form_namespace, "#{attribute_name}_cont", value: value, class: 'form-control')
      end
    end
  end
end
