module Table
  class TextBuilder < Table::BaseBuilder
    def render object, attribute_name, options = {}
      classes = options[:class].present? ? options[:class] : " #{attribute_name} "

      haml_tag :td, object.send(attribute_name), { class: classes}
    end
  end
end