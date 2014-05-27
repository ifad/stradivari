require 'active_support/concern'

module Table
  module Helpers
    module Generator
      extend ActiveSupport::Concern

      def table_for data, options = {}, &block
        Table::Generator.generate_table_for data, _options_for(options), &block
      end

      def csv_for data, options = {}, &block
        Table::Generator.generate_csv_for data, _options_for(options), &block
      end

      def filter_for class_object, options = {}, &block
        options.merge!({env: request.env, controller: controller, Filter::NAMESPACE => params[Filter::NAMESPACE] || {}})
        Filter::Generator.generate_filter_for class_object, options, &block
      end

      def search_param(name)
        params[Filter::NAMESPACE].try(:[], name).presence
      end

      protected

        def _options_for options = {}
          local_controller = self.class.ancestors.include?(ApplicationController) ? self : controller

          options.merge!({sortable: sortable, env: request.env, controller: options[:controller] || local_controller})
        end

    end
  end
end
