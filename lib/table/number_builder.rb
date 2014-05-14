
module Table
  class NumberBuilder < Table::BaseBuilder
    def render object, attribute_name, options = {}
      classes = options[:class].present? ? options[:class] : ""

      haml_tag :td, object.send(attribute_name), {class: classes}
    end
  end
end