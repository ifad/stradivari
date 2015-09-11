module Stradivari

  class Generator
    include Stradivari::Concerns::CssFriendly

    class Tag
    include Stradivari::Concerns::CssFriendly

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

      def title
        case t = opts[:title]
        when nil
          human_attribute_name
        when Proc
          view.instance_eval(&t)
        when false
          ""
        else
          t
        end
      end

      protected
        def human_attribute_name
          if klass.respond_to?(:human_attribute_name)
            klass.human_attribute_name(name)
          else
            name.to_s.titleize
          end
        end

        def force_presence(value)
          if @opts.fetch(:present, nil)
            value.presence || t(:empty).html_safe
          else
            value
          end
        end

        def type
          klass.stradivari_type(name)
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
