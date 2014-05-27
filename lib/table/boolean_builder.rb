module Table
  class BooleanBuilder < Table::BaseBuilder

    def render object, attribute_name, options = {}
      @haml_buffer = options[:haml_buffer]

      object.send(attribute_name) ? "Yes" : "No"
    end
  end
end
