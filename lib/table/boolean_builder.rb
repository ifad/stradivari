module Table
  class BooleanBuilder
    def self.render
      lambda do |object, attr, _|
        object.send(attr) ? "Yes" : "No"
      end
    end
  end
end
