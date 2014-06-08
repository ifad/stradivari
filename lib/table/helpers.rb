require 'active_support/concern'

module Table
  module Helpers
      extend ActiveSupport::Concern

      def table_for *pass, &block
        options = pass.extract_options!
        data    = pass.first

        Table::Generator.new(self, data, _options_for(options)).tap {|table| table.instance_exec(*pass, &block) }.to_s
      end

      def csv_for *pass, &block
        options = pass.extract_options!
        data    = pass.first

        options.merge!(format: :csv)

        Table::Generator.new(self, data, _options_for(options)).tap {|table| table.instance_exec(*pass, &block) }.to_s
      end

      def details_for *pass, &block
        options = pass.extract_options!
        data    = pass.first

        Details::Generator.new(self, data, options).tap {|detail| detail.instance_exec(*pass, &block) }.to_s
      end

      def filter_for *pass, &block
        options = pass.extract_options!
        data    = pass.first

        options.merge!({env: request.env, controller: controller, Filter::NAMESPACE => params[Filter::NAMESPACE] || {}})

        Filter::Generator.new(self, data, options).tap {|filter| filter.instance_exec(*pass, &block) }.to_s
      end

      def search_param(name)
        params[Filter::NAMESPACE].try(:[], name).presence
      end

      def tabs_for(*pass, &block)
        options = pass.extract_options!
        data    = pass.first

        Tabs::Generator.new(self, data, options).tap {|tabs| tabs.instance_exec(*pass, &block) }.to_s
      end

      protected

        def _options_for options = {}
          local_controller = self.class.ancestors.include?(ApplicationController) ? self : controller

          options.merge!({sortable: sortable, env: request.env, controller: options[:controller] || local_controller})
        end

  end
end
