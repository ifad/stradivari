module Table
  class TextLinkBuilder
    def self.render
      lambda do |object, attr, _|
        if name = object.send(attr)
          link_to(name, object)
        end
      end
    end
  end
end
