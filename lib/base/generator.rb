module Base

  class Generator
    class Tag
      delegate :view, :klass, to: :@parent
      delegate :t, :capture_haml, :haml_tag, :haml_concat, to: :view

      def initialize(parent, opts)
        @parent = parent
        @opts   = opts
      end

      protected
        def force_presence(value)
          if @opts.fetch(:present, nil)
            value.presence || t(:empty).html_safe
          else
            value
          end
        end
    end

    def initialize(view, data, opts = {})
      @view = view
      @data = data
      @opts = opts
    end

    attr_reader :view, :opts

    delegate :capture_haml, :haml_tag, to: :@view

    def to_s
      raise "To be implemented"
    end

    def klass
      @klass ||= @data.try(:klass) || (@data.try(:first).presence || @data).class
    end

    def method_missing name, *args, &block
      begin
        @view.send(name, *args)
      rescue
        super
      end
    end

  end
end
