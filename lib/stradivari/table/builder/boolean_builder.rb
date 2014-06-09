module Stradivari
  module Table
    class Builder::BooleanBuilder < Builder
      def self.render
        lambda do |object, attr, _|
          object.send(attr) ? "Yes" : "No"
        end
      end
    end
  end
end
