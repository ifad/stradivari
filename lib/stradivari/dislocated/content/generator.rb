module Stradivari
  module Dislocated
    module Content

      class Generator < Stradivari::Generator
        class Tab < Tag
          def initialize(parent, dom_id, content, opts, renderer)
            super(parent, opts)
  
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
  
          def content(opts = {})
            klass = 'tab-pane'
            klass << ' active' if active?
  
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
  
        def tab(dom_id, content=[], opts = {}, &renderer)
          if (tab = self.class.const_get(:Tab).new(self, dom_id, content, opts, renderer)).enabled?
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
                haml_tag(:div) { tab.content(blank: blank) }
              end
            end
  
          else
            lambda do
              tabs.first.opts[:active] = true if tabs.none? {|tab| tab.opts.fetch(:active, false)}
  
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
end
