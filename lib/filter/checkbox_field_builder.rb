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
          if type == :multi_line
            # Display checked items first
            checked, unchecked = collection.partition {|_, value| values.include?(value.to_s)}

            checked  .each {|label, value| check_box(name, label, value, true) }
            haml_tag :hr
            unchecked.each {|label, value| check_box(name, label, value, false)}
          else
            collection.each do |label, value|
              check_box(name, label, value, values.include?(value.to_s))
            end
          end
        end

      end
    end

    private
      def check_box(name, label, value, checked)
        haml_tag :div, class: 'checkbox' do
          haml_tag :label, class: 'checkbox-field' do
            haml_concat super(@@form_namespace, name, {multiple: true, value: value, checked: checked}, value, nil)
            haml_concat label
          end
        end
      end

  end
end
