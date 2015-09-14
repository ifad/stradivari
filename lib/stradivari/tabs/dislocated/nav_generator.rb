module Stradivari
  module Tabs
    module Dislocated

      class NavGenerator < Stradivari::Tabs::Generator
  
        def initialize(view, *pass, &definition)
          super
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
