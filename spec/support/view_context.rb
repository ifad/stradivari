module ViewContext
  # Builds a real ActionView::Base instance with StradivariHelper + Haml::Helpers
  # mixed in. Used by unit specs that need to invoke generators directly outside
  # the controller request cycle.
  def view_context(params: {})
    lookup_context = ActionView::LookupContext.new([])
    controller = ActionController::Base.new
    controller.request = ActionDispatch::Request.new('rack.input' => StringIO.new)
    controller.response = ActionDispatch::Response.new
    controller.params = ActionController::Parameters.new(params)
    # Wire the application routes into the controller so url helpers (link_to(record),
    # polymorphic_path, etc.) can resolve when generators render outside a request.
    controller.singleton_class.include(Rails.application.routes.url_helpers)
    controller.request.env['action_dispatch.routes'] = Rails.application.routes

    view = ActionView::Base.with_empty_template_cache.new(lookup_context, {}, controller)
    view.singleton_class.include(StradivariHelper)
    view.singleton_class.include(Rails.application.routes.url_helpers)
    view.singleton_class.include(Haml::Helpers)
    view.init_haml_helpers
    view
  end

  # Renders the given HAML source against a fresh view_context. Returns the HTML.
  def render_haml(template, params: {}, locals: {})
    view = view_context(params: params)
    engine = Haml::Engine.new(template)
    locals.each { |k, v| view.instance_variable_set("@#{k}", v) }
    view.instance_eval(&engine.precompiled_method)
    # When precompiled_method is unavailable, fall back to render
  rescue NoMethodError
    view = view_context(params: params)
    view.render(inline: template, type: :haml, locals: locals)
  end

  # Convenience: parse arbitrary HTML into a Nokogiri fragment.
  def html(string)
    Nokogiri::HTML.fragment(string)
  end
end
