module Filter
  class FullTextSearchFieldBuilder < Filter::BaseFieldBuilder
    def render object_class, attribute_name, options = {}
      haml_tag :div, class: 'form-group' do
        value = options[:value]
        if options[:skip_button]
          haml_concat label(@@form_namespace, attribute_name, options[:title] || "Search #{attribute_name.to_s.humanize}")
          haml_concat text_field(@@form_namespace, attribute_name, value: value, class: 'form-control', placeholder: options[:title] || "Search #{attribute_name.to_s.humanize}")
        else
          haml_tag :div, class: 'input-group' do
            haml_concat text_field(@@form_namespace, attribute_name, value: value, class: 'form-control', placeholder: options[:title] || "Search #{attribute_name.to_s.humanize}")
            haml_tag :span, class: 'input-group-btn' do
              haml_tag :button, type: 'button', class: 'btn btn-primary search' do
                haml_tag :i, class: 'fa fa-search'
                haml_concat 'Search'
              end
            end
          end
        end
      end
    end
  end
end
