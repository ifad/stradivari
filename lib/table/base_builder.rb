module Table
  class BaseBuilder
    include Haml::Helpers
    include ActionView::Helpers::UrlHelper
    # include ActionView::AssetPaths
    include ActionView::Helpers::AssetTagHelper
    # include ActionController::UrlFor
    # include ActionView::Helpers::TagHelper
    include Rails.application.routes.url_helpers
    include HistoryHelper

    def controller
      @controller || ApplicationController
    end

    def initialize(options = {})
      if options[:haml_buffer].present?
        @haml_buffer = options[:haml_buffer]
      else
        self.init_haml_helpers
      end


      @controller = options[:controller] if options[:controller].present?

      self
    end

    def self.generate_field object, attribute_name, options = {}
      builder = self.new(options)
      builder.render(object, attribute_name, options)
    end

    def render object, attribute_name, options = {}
      raise "Override this method in inherited class"
    end

  end
end
