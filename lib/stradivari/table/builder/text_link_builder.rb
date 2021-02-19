# frozen_string_literal: true

module Stradivari
  module Table
    class Builder::TextLinkBuilder < Builder
      def self.render
        lambda do |object, attr, _|
          if name = object.send(attr)
            link_to(name, object)
          end
        end
      end
    end
  end
end
