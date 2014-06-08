module Table
  class DateBuilder
    def self.render
      lambda do |object, attr, _|
        history_timestamp(object, attr) if object.send(attr).present?
      end
    end
  end
end
