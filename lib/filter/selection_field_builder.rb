module Filter
  class SelectionFieldBuilder < Filter::BaseFieldBuilder
    def render object_class, attribute_name, options = {}
      value = options[:value]
      collection = options[:collection].is_a?(Proc) ? options[:collection].call : options[:collection]
      input_name = options[:field_name].present? ? options[:field_name] : attribute_name
      
      field_name = if options[:attribute_type] == :ransack
        input_name
      else
        "#{input_name}_eq"
      end

      haml_tag :div, class: "form-group" do
        haml_concat label(@@form_namespace, field_name, options[:title] || attribute_name.to_s.humanize)
        haml_concat select(@@form_namespace, field_name, collection, {selected: value, include_blank: 'Any'}, {class: 'form-control'})
      end
    end
  end
end
