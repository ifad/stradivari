module Stradivari
  module Concerns
    module TableBuilder
      extend ActiveSupport::Concern

      def builder
        @builder ||= if (b = @opts[:builder]).present?
          b
        else
          case type
          when :integer
            Table::NumberBuilder
          when :date
            Table::DateBuilder
          when :datetime
            Table::DateBuilder
          when :boolean
            Table::BooleanBuilder
          else
            Table::TextBuilder
          end
        end
      end
    end
  end
end
