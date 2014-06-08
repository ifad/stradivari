module Table
  class TextBuilder
    def self.render
      lambda do |object, attr, _|
        object.send(attr)
      end
    end
  end
end
