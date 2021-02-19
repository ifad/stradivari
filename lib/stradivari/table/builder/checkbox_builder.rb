# frozen_string_literal: true

module Stradivari
  module Table
    class Builder::CheckboxBuilder < Builder
      def self.render
        lambda do |_, _, _|
          ''
        end
      end
    end
  end
end
