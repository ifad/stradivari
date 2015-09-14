module Stradivari
  module Tabs
    module Dislocated

      class ContentGenerator < Stradivari::Tabs::Generator
  
        def initialize(view, *pass, &definition)
          super
        end
  
        def tab(dom_id, content=[], opts = {}, &renderer)
          super 'label', dom_id, content, opts, &renderer
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
