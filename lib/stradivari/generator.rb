module Stradivari

  class Generator
    class Tag
      delegate :view, :klass, to: :@parent
      delegate :t, :capture_haml, :haml_tag, :haml_concat, to: :view

      attr_reader :opts

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

        def type
          object_columns_hash = klass.try(:extra_columns_hash) || klass.columns_hash

          object_columns_hash.fetch(name.to_s, nil).try(:type)
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
      raise "To be implemented"
    end

  end
end
