module Table
  class BooleanBuilder < Table::BaseBuilder

    def render object, attribute_name, options = {}
      object.send(attribute_name) ? "Yes" : "No"
    end
  end
end
