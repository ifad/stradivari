module Stradivari
  module Tabs

    class Generator < Stradivari::Generator
      class Tab < Tag
        def initialize(parent, label, dom_id, content, opts, renderer)
          super(parent, opts)

          @label    = label
          @dom_id   = dom_id
          @content  = content
          @renderer = renderer
        end

        def blank?
          @content.blank? && !opts.fetch(:present, false)
        end

        def nav(opts = {})
          klass = 'active' if opts.fetch(:active, false)

          haml_tag :li, class: klass do
            haml_tag :a, @opts.deep_merge(href: "##@dom_id", data: {toggle: :tab}) do
              haml_concat @label

              if opts.fetch(:badge) && @content.respond_to?(:count)
                haml_tag :span, @content.count, class: 'badge alert-info'
              end
            end
          end
        end

        def content(opts = {})
          klass = 'tab-pane'
          klass << ' active' if opts.fetch(:active, false)

          haml_tag :div, class: klass, id: @dom_id do
            renderer = @content.blank? ? opts.fetch(:blank) : @renderer
            view.instance_exec(@content, &renderer)
          end
        end
      end

      def initialize(view, *pass, &definition)
        @tabs = []

        super(view, nil, *pass)

        instance_exec(*pass, &definition)
      end

      def tab(label, dom_id, content, opts = {}, &renderer)
        @tabs.push Tab.new(self, label, dom_id, content, opts, renderer)
      end

      def blank(&block)
        @blank = block
      end

      def to_s
        tabs = @tabs.reject(&:blank?)
        blank = @blank || lambda { }

        renderer = if tabs.blank?
          blank
        elsif @opts.fetch(:printable, false)
          lambda do
            nav_opts = {badge: @opts.fetch(:counters, true)}
            tabs.each do |tab|
              haml_tag(:h5) do
                haml_tag(:ul, class: 'list-unstyled') { tab.nav(nav_opts) }
              end
              haml_tag(:div) { tab.content(blank: blank) }
            end
          end

        else
          lambda do
            flavor = @opts.fetch(:flavor, 'tabs')
            nav_opts = {badge: @opts.fetch(:counters, true)}

            active, *others = tabs # TODO allow driving from the outside

            # Navigation
            haml_tag :ul, class: "nav nav-#{flavor}" do
              active.nav(nav_opts.merge(active: true))
              others.each {|tab| tab.nav(nav_opts) }
            end

            # Content
            haml_tag :div, class: 'tab-content' do
              active.content(active: true, blank: blank)
              others.each {|tab| tab.content(blank: blank)}
            end
          end
        end

        capture_haml(&renderer)
      end

    end
  end
end
