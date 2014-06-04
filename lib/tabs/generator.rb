module Tabs

  class Generator
    def initialize(view, options = {})
      @view = view
      @tabs = []
      @opts = options
    end

    delegate :capture_haml, :haml_tag, to: :@view

    def tab(label, dom_id, content, options = {}, &renderer)
      @tabs.push Tab.new(@view, label, dom_id, content, options, renderer)
    end

    def blank(&block)
      @blank = block
    end

    def render
      tabs = @tabs.reject(&:blank?)

      renderer = if tabs.blank?
        @blank || lambda { }
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
            active.content(active: true)
            others.each {|tab| tab.content}
          end
        end
      end

      capture_haml(&renderer)
    end
    alias :to_s :render

    class Tab
      def initialize(view, label, dom_id, content, options, renderer)
        @view     = view
        @label    = label
        @dom_id   = dom_id
        @content  = content
        @options  = options
        @renderer = renderer
      end

      delegate :blank?, to: :@content
      delegate :capture_haml, :haml_tag, :haml_concat, to: :@view

      def nav(options = {})
        klass = 'active' if options.fetch(:active, false)

        haml_tag :li, class: klass do
          haml_tag :a, @options.deep_merge(href: "##@dom_id", data: {toggle: :tab}) do
            haml_concat @label

            if options.fetch(:badge) && @content.respond_to?(:count)
              haml_tag :span, @content.count, class: 'badge alert-info'
            end
          end
        end
      end

      def content(options = {})
        klass = 'tab-pane'
        klass << ' active' if options.fetch(:active, false)

        haml_tag :div, class: klass, id: @dom_id do
          @view.instance_exec(@content, &@renderer)
        end
      end
    end

  end
end
