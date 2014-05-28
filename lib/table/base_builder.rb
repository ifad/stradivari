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
      self.init_haml_helpers

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
