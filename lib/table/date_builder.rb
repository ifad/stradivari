module Table
  class DateBuilder < Table::BaseBuilder

    def render object, attribute_name, options = {}
      @haml_buffer = options[:haml_buffer]

      if object.send(attribute_name).present?
        history_timestamp(object, attribute_name)
      else
        '-'
      end
    end
  end
end
