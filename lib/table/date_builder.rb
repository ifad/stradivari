module Table
  class DateBuilder < Table::BaseBuilder

    def render object, attribute_name, options = {}
      history_timestamp(object, attribute_name) if object.send(attribute_name).present?
    end
  end
end
