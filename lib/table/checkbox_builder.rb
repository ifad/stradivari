module Table
  class CheckboxBuilder < Table::BaseBuilder
    def render object, attribute_name, options = {}
      classes = options[:class].present? ? options[:class] : ""

      haml_tag :td, '', { class: classes }
    end
  end
end