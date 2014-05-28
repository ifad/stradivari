module Filter
  class BaseFieldBuilder
    include Haml::Helpers
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::FormHelper
    include ActionView::Helpers::FormOptionsHelper
    include Rails.application.routes.url_helpers

    @@form_namespace = Filter::NAMESPACE

    def controller
      ApplicationController
    end

    def initialize(options = {})
      self.init_haml_helpers

      self
    end

    def self.generate_field object_class, attribute_name, options = {}
      builder = self.new(options)
      builder.render(object_class, attribute_name, options)
    end

    def render object_class, attribute_name, options = {}
      raise "Override this method in inherited class"
    end
  end
end
