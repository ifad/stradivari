module Table
  class DateBuilder < Table::BaseBuilder

    def render object, attribute_name, options = {}
      @haml_buffer = options[:haml_buffer]

      classes = options[:class].present? ? options[:class] : " #{attribute_name} "

      date = object.send(attribute_name)
      value = date.present? ? history_timestamp(object, attribute_name) : '-'
      haml_tag :td, value, class: classes
    end
  end
end
