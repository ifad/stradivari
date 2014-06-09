module Stradivari
  module Table
    class Builder::DateBuilder < Builder
      def self.render
        lambda do |object, attr, _|
          if (d=object.public_send(attr)).present?
            I18n.l(d)
          end
        end
      end
    end
  end
end
