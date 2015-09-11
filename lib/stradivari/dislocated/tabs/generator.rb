module Stradivari
  module Dislocated
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
            end
          end
  
          capture_haml(&renderer)
        end
  
      end

    end
  end
end
