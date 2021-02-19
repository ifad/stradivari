# frozen_string_literal: true

module Stradivari
  class Builder
    class << self
      def self.render
        raise NotImplementedError
      end
    end
  end
end
