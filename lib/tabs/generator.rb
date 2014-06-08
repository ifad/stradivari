module Tabs

  class Generator < ::Base::Generator
    class Tab < Tag
      def initialize(parent, label, dom_id, content, opts, renderer)
        @parent   = parent
        @label    = label
        @dom_id   = dom_id
        @content  = content
        @opts     = opts
        @renderer = renderer
      end

      delegate :blank?, to: :@content

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
          view.instance_exec(@content, &@renderer)
        end
      end
    end

    def initialize(*)
      super

      @tabs = []
    end

    def tab(label, dom_id, content, opts = {}, &renderer)
      @tabs.push Tab.new(self, label, dom_id, content, opts, renderer)
    end

    def blank(&block)
      @blank = block
    end

    def to_s
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

  end
end
