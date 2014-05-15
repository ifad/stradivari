module Filter
  class DateRangeFieldBuilder < Filter::BaseFieldBuilder
    def render object_class, attribute_name, options = {}
      from_value = options[:value].first
      to_value   = options[:value].last

      input_name = options[:field_name].present? ? options[:field_name] : attribute_name

      haml_tag :div, class: "row form-inline" do
        haml_tag :fieldset do
          haml_concat label(@@form_namespace, input_name, options[:title] || attribute_name.to_s.humanize, for: 'date')
          haml_tag :br
          haml_tag :div, class: "form-group input-daterange table-datepicker" do
            value = options[:value]
            haml_concat text_field(@@form_namespace, "#{input_name}_gteq", {value: from_value, class: 'form-control'})
          end
          haml_tag :div, class: "form-group delimiter" do
            haml_tag :label, "-"
          end
          haml_tag :div, class: "form-group input-daterange table-datepicker" do
            value = options[:value]
            haml_concat text_field(@@form_namespace, "#{input_name}_lteq", {value: to_value, class: 'form-control'})
          end
        end
      end
    end
  end
end
