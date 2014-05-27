
module Table
  class TextLinkBuilder < Table::BaseBuilder
    def render object, attribute_name, options = {}
      if name = object.send(attribute_name)
        link_to(name, object)
      else
        ""
      end
    end
  end
end
