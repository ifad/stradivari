module Filter
  class CheckboxFieldBuilder < Filter::BaseFieldBuilder
    def render object_class, attribute_name, options = {}
      type = options[:type] || :single_line
      values = options[:value] || []

      name = options[:scope] || "#{attribute_name}_in"
      if type == :single_line
        listing_type = "single-line form-inline"
      else
        listing_type = "multi-line"
      end

      haml_tag :div, class: "form-group #{listing_type}" do
        haml_concat label(@@form_namespace, name, options[:title] || attribute_name.to_s.humanize)

        classes = "checkbox-field #{listing_type}"
        collection = options[:collection].is_a?(Proc) ? options[:collection].call : options[:collection]

        haml_tag :div, class: listing_type do
          collection.each do |item|
            if type == :single_line
              # build single line multiple selection
              haml_tag :div, class: 'checkbox' do
                haml_tag :label, class: classes do
                  haml_concat check_box(@@form_namespace, name, { multiple: true, value: item.last, checked: values.include?(item.last.to_s) }, item.last, nil)
                  haml_concat item.first
                end
              end
            else
              # build multi line multiple selection
              
              haml_tag :div, class: 'checkbox' do
                haml_tag :label, class: classes do
                  haml_concat check_box(@@form_namespace, name, { multiple: true, value: item.last, checked: values.include?(item.last.to_s) }, item.last, nil)
                  haml_concat item.first
                end
              end
            end

          end
        end
      end
    end
  end
end
