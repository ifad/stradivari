# frozen_string_literal: true

module Stradivari
  module Table
    class Builder::TextBuilder < Builder
      def self.render
        lambda do |object, attr, _|
          object.send(attr)
        end
      end
    end
  end
end
