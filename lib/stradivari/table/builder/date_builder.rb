# frozen_string_literal: true

module Stradivari
  module Table
    class Builder::DateBuilder < Builder
      def self.render
        lambda do |object, attr, opts|
          if (d = object.public_send(attr)).present?
            if f = opts.fetch(:format, nil)
              d.strftime(f)
            else
              I18n.l(d)
            end
          end
        end
      end
    end
  end
end
