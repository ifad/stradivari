module Stradivari
  module ClassNames
    module_function

    def join(*classes)
      classes.flatten.compact.each_with_object([]) do |value, tokens|
        value.to_s.split.each do |token|
          tokens << token unless token.empty? || tokens.include?(token)
        end
      end.join(' ')
    end

    def modifier(base_class, modifier, enabled: true)
      return unless enabled

      "#{base_class}--#{modifier.to_s.tr('_', '-')}"
    end
  end
end
