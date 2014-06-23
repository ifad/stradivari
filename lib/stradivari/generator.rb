module Stradivari

  class Generator
    class Tag
      delegate :view, :klass, to: :@parent
      delegate :t, :capture_haml, :haml_tag, :haml_concat, to: :view

      attr_reader :opts

      def initialize(parent, opts)
        @parent, @opts = parent, opts
      end

      def enabled?
        enabled = true

        if i = @opts.fetch(:if, nil)
          enabled &= view.instance_exec(&i)
        elsif u = @opts.fetch(:unless, nil)
          enabled &= !view.instance_exec(&u)
        end

        enabled
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
          klass.columns_hash.fetch(name.to_s, nil).try(:type)
        end

    end

    def initialize(view, data, *pass)
      # ActionView
      @view = view

      # Opaque, generator-specific data
      @data = data

      # Generator options
      @opts = pass.extract_options!
    end

    attr_reader :view, :data, :opts

    delegate :params, :t, :capture_haml, :haml_tag, to: :@view

    def to_s
      raise NotImplementedError
    end

    def klass
      raise NotImplementedError
    end

  end
end
