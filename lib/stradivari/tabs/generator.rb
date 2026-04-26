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
          @content.blank? && !present
        end

        def active?
          @opts.fetch(:active, false)
        end

        def present
          @opts.fetch(:present, false)
        end

        def force?
          present == :force
        end

        def nav(global_opts = {})
          klass = Stradivari::ClassNames.join(
            'stradivari-tabs__item',
            Stradivari::ClassNames.modifier('stradivari-tabs__item', :active, enabled: active?)
          )

          attributes = @opts.except(:if, :url)
          attributes.deep_merge!(href: "##{@dom_id}", class: 'stradivari-tabs__link', data: { stradivari_tab: true })
          attributes[:data][:url] = @opts[:url]

          concat(
            content_tag(:li, class: klass) do
              concat(
                content_tag(:a, attributes) do
                  concat @label
                  counter global_opts
                end
              )
            end
          )
        end

        def content(opts = {})
          klass = Stradivari::ClassNames.join(
            'stradivari-tabs__pane',
            Stradivari::ClassNames.modifier('stradivari-tabs__pane', :active, enabled: active?)
          )

          concat(
            content_tag(:div, class: klass, id: @dom_id) do
              renderer = @content.blank? && !force? ? opts.fetch(:blank) : @renderer
              view.instance_exec(@content, &renderer)
            end
          )
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
          concat content_tag(:span, count, class: 'stradivari-tabs__badge')
        end
      end

      def tab(label, dom_id, content, opts = {}, &renderer)
        if (tab = self.class.const_get(:Tab).new(self, label, dom_id, content, opts, renderer)).enabled?
          @tabs << tab
        end
      end

      alias tab_nav tab

      def tab_content(dom_id, content, opts = {}, &)
        tab('label', dom_id, content, opts, &)
      end

      def blank(&block)
        @blank = block if block
        @blank || proc {}
      end

      def to_s
        tabs = @tabs.compact_blank

        renderer = if tabs.blank?
                     blank
                   elsif @opts.fetch(:printable, false)
                     render_for_print(tabs)
                   else
                     render_for_display(tabs)
                   end

        capture(&renderer)
      end

      class << self
        def tabs(view, *pass, &)
          new(view, true, true, *pass, &)
        end

        def navs(view, *pass, &)
          new(view, true, false, *pass, &)
        end

        def content(view, *pass, &)
          new(view, false, true, *pass, &)
        end
      end

      protected

      def initialize(view, render_nav, render_content, *pass, &)
        super(view, nil, *pass)

        @tabs           = []
        @render_nav     = render_nav
        @render_content = render_content

        instance_exec(*pass, &)
      end

      def render_for_print(tabs)
        lambda do
          tabs.each do |tab|
            if @render_nav
              concat(
                content_tag(:h5) do
                  concat(content_tag(:ul, class: 'stradivari-tabs__print-nav') { tab.nav(@opts) })
                end
              )
            end
            concat(content_tag(:div) { tab.content(blank: blank) }) if @render_content
          end
        end
      end

      def render_for_display(tabs)
        lambda do
          flavor = @opts.fetch(:flavor, 'tabs')

          tabs.first.opts[:active] = true if tabs.none? { |tab| tab.opts.fetch(:active, false) }

          if @render_nav
            concat(
              content_tag(:ul, class: Stradivari::ClassNames.join('stradivari-tabs__nav', Stradivari::ClassNames.modifier('stradivari-tabs__nav', flavor))) do
                tabs.each { |tab| tab.nav(@opts) }
              end
            )
          end

          if @render_content
            concat(
              content_tag(:div, class: 'stradivari-tabs__content') do
                tabs.each { |tab| tab.content(blank: blank) }
              end
            )
          end
        end
      end
    end
  end
end
