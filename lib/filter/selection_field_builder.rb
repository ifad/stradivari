module Filter
  class SelectionFieldBuilder < Filter::BaseFieldBuilder
    def render object_class, attribute_name, options = {}
      @value = options[:value]
      @collection = options[:collection].is_a?(Proc) ? options[:collection].call : options[:collection]
      input_name = options[:field_name].present? ? options[:field_name] : attribute_name

      @title = options.fetch(:title, attribute_name.to_s.humanize)
      @field_name = if options[:attribute_type] == :ransack
        input_name
      else
        "#{input_name}_eq"
      end

      haml_tag :div, class: 'form-group' do
        haml_concat label(@@form_namespace, @field_name, @title)

        (@collection.kind_of?(Array) && @collection.size <= 5) ? radios : dropdown
      end
    end


    private
      def dropdown
        haml_concat select(@@form_namespace, @field_name, @collection, {selected: @value, include_blank: 'Any'}, {class: 'form-control'})
      end

      def radios
        haml_tag :div, class: 'form-inline' do
          any_checked = true

          @collection.each do |title, value|
            haml_tag :div, class: 'radio' do
              checked = (@value.to_s == value.to_s)
              any_checked = false if checked

              haml_tag :label do
                haml_concat radio_button(@@form_namespace, @field_name, value, checked: checked)
                haml_concat title
              end
            end
          end

          haml_tag :div, class: 'radio' do
            haml_tag :label do
              haml_concat radio_button(@@form_namespace, @field_name, '', checked: any_checked)
              haml_concat 'Any'
            end
          end
        end
      end
  end
end
