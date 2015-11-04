module Stradivari
  module Tabs

    class Generator < Stradivari::Generator
      class Tab < Tag
        def initialize(parent, label, dom_id, content, opts, renderer)
          super(parent, opts)

          @label    = label
          @dom_id   = css_friendly(dom_id)
          @content  = content
          @renderer = renderer
        end

        def blank?
          @content.blank? && !opts.fetch(:present, false)
        end

        def active?
          @opts.fetch(:active, false)
        end

        def nav(global_opts = {})
          klass = 'active' if active?

          attributes = @opts.except(:if, :url)
          attributes.deep_merge!(href: "##@dom_id", data: {toggle: :tab})
          attributes[:data][:url] = @opts[:url]

          haml_tag :li, class: klass do
            haml_tag :a, attributes do
              haml_concat @label
              counter global_opts
            end
          end
        end

        def content(opts = {})
          klass = 'tab-pane'
          klass << ' active' if active?

          haml_tag :div, class: klass, id: @dom_id do
            renderer = @content.blank? ? opts.fetch(:blank) : @renderer
            view.instance_exec(@content, &renderer)
          end
        end

        def counter(global_opts = {})
          # @opts are this tab's options, while global_opts are options coming
          # from the tabs generator.
          counter = if @opts.key?(:counter)
            @opts.fetch(:counter, nil)
          else
            global_opts.fetch(:counters, true)
          end

          return unless counter

          count = @content.respond_to?(:count) ? @content.count : counter
          haml_tag :span, count, class: 'badge alert-info'
        end
      end

      def tab(label, dom_id, content, opts = {}, &renderer)
        if (tab = self.class.const_get(:Tab).new(self, label, dom_id, content, opts, renderer)).enabled?
          @tabs << tab
        end
      end

      alias_method :tab_nav, :tab

      def tab_content(dom_id, content, opts = {}, &renderer)
        tab 'label', dom_id, content, opts, &renderer
      end

      def blank(&block)
        @blank = block if block
        @blank || Proc.new { }
      end

      def to_s
        tabs = @tabs.reject(&:blank?)

        renderer = if tabs.blank?
          blank
        elsif @opts.fetch(:printable, false)
          render_for_print(tabs)
        else
          render_for_display(tabs)
        end

        capture_haml(&renderer)
      end

      class << self
        def tabs view, *pass, &definition
          new(view, true, true, *pass, &definition)
        end

        def navs view, *pass, &definition
          new(view, true, false, *pass, &definition)
        end

        def content view, *pass, &definition
          new(view, false, true, *pass, &definition)
        end
      end

    protected

      def initialize(view, render_nav, render_content, *pass, &definition)
        super(view, nil, *pass)

        @tabs           = []
        @render_nav     = render_nav
        @render_content = render_content

        instance_exec(*pass, &definition)
      end

      def render_for_print tabs
        lambda do
          tabs.each do |tab|
            if @render_nav
              haml_tag(:h5) do
                haml_tag(:ul, class: 'list-unstyled') { tab.nav(@opts) }
              end
            end
            if @render_content
              haml_tag(:div) { tab.content(blank: blank) }
            end
          end
        end
      end

      def render_for_display tabs
        lambda do
          flavor = @opts.fetch(:flavor, 'tabs')

          tabs.first.opts[:active] = true if tabs.none? {|tab| tab.opts.fetch(:active, false)}

          if @render_nav
            haml_tag :ul, class: "nav nav-#{flavor}" do
              tabs.each {|tab| tab.nav(@opts) }
            end
          end

          if @render_content
            haml_tag :div, class: 'tab-content' do
              tabs.each {|tab| tab.content(blank: blank)}
            end
          end
        end
      end
    end
  end
end
