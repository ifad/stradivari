require 'active_support/concern'

module Stradivari
  module Helpers
      extend ActiveSupport::Concern

      def table_for *args, &block
        Stradivari::Table::Generator.new(self, *args, &block).to_s
      end

      def csv_for *args, &block
        Stradivari::CSV::Generator.new(self, *args, &block).to_s
      end

      def details_for *args, &block
        Stradivari::Details::Generator.new(self, *args, &block).to_s
      end

      def filter_for *args, &block
        Stradivari::Filter::Generator.new(self, *args, &block).to_s
      end

      def tabs_for(*args, &block)
        Stradivari::Tabs::Generator.new(self, *args, &block).to_s
      end

      def search_param(name)
        params[Stradivari::Filter::NAMESPACE].try(:[], name).presence
      end
  end
end
