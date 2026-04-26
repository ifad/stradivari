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
                         Stradivari::Table::Builder::NumberBuilder
                       when :date, :datetime
                         Stradivari::Table::Builder::DateBuilder
                       when :boolean
                         Stradivari::Table::Builder::BooleanBuilder
                       else
                         Stradivari::Table::Builder::TextBuilder
                       end
                     end
      end
    end
  end
end
