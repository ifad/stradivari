module Stradivari
  module Tabs

    class Generator < Stradivari::Generator
      class Tab < Tag
        def initialize(parent, label, dom_id, content, opts, renderer)
          super(parent, opts)

          @label    = label
          @dom_id   = self.class.css_friendly(dom_id)
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

        # If the dom_id has css selector characters in them, it will muck up any search,
        # so this method converts the dom_id to a less dangerous form.
        def self.css_friendly dom_id
          dom_id.gsub( /[\[\]:.]/, '_' )
        end
      end

      def initialize(view, *pass, &definition)
        @tabs = []

        super(view, nil, *pass)

        instance_exec(*pass, &definition)
      end

      def tab(label, dom_id, content, opts = {}, &renderer)
        if (tab = self.class.const_get(:Tab).new(self, label, dom_id, content, opts, renderer)).enabled?
          @tabs << tab
        end
      end

      def blank(&block)
        @blank = block
      end

      def to_s
        tabs = @tabs.reject(&:blank?)
        blank = @blank || Proc.new { }

        renderer = if tabs.blank?
          blank
        elsif @opts.fetch(:printable, false)
          lambda do
            tabs.each do |tab|
              haml_tag(:h5) do
                haml_tag(:ul, class: 'list-unstyled') { tab.nav(@opts) }
              end
              haml_tag(:div) { tab.content(blank: blank) }
            end
          end

        else
          lambda do
            flavor = @opts.fetch(:flavor, 'tabs')

            tabs.first.opts[:active] = true if tabs.none? {|tab| tab.opts.fetch(:active, false)}

            # Navigation
            haml_tag :ul, class: "nav nav-#{flavor}" do
              tabs.each {|tab| tab.nav(@opts) }
            end

            # Content
            haml_tag :div, class: 'tab-content' do
              tabs.each {|tab| tab.content(blank: blank)}
            end
          end
        end

        capture_haml(&renderer)
      end

    end
  end
end
