
module Table
  class TextLinkBuilder < Table::BaseBuilder
    def render object, attribute_name, options = {}
      classes = options[:class].present? ? options[:class] : " #{attribute_name} "

      name    = object.send(attribute_name)
      content = name.present? ? link_to(name, object) : ""

      haml_tag :td, content, { class: classes}
    end
  end
end