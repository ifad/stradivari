module Filter
  class CheckboxFieldBuilder < BaseFieldBuilder

    def render object_class, attribute_name, options = {}
      type   = options.fetch :type , :single_line
      title  = options.fetch :title, attribute_name.to_s.humanize
      name   = options.fetch :scope, "#{attribute_name}_in"
      values = options.fetch :value, nil

      values   ||= []
      collection = options[:collection]
      collection = collection.call if collection.respond_to?(:call)

      haml_tag :div, class: 'form-group' do
        haml_concat label(@@form_namespace, name, title)

        haml_tag :div, class: (type == :single_line ? 'form-inline' : 'multi-line') do
          collection.each do |item|
            key, value = item

            haml_tag :div, class: 'checkbox' do
              haml_tag :label, class: 'checkbox-field' do
                haml_concat check_box(@@form_namespace, name, {multiple: true, value: value, checked: values.include?(value.to_s)}, value, nil)
                haml_concat key
              end
            end
          end
        end

      end
    end

  end
end
