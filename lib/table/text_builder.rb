module Table
  class TextBuilder < Table::BaseBuilder
    def render object, attribute_name, options = {}
      object.send(attribute_name)
    end
  end
end
