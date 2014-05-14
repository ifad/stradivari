module Table
  class BooleanBuilder < Table::BaseBuilder

    def render object, attribute_name, options = {}
      @haml_buffer = options[:haml_buffer]
      classes = options[:class].present? ? options[:class] : ""

      text = object.send(attribute_name) ? "Yes" : "No"
      haml_tag :td, text, { class: classes }
    end
  end
end