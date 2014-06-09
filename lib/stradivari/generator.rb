module Stradivari

  class Generator
    class Tag
      delegate :view, :klass, to: :@parent
      delegate :t, :capture_haml, :haml_tag, :haml_concat, to: :view

      attr_reader :opts

      def initialize(*args, &block)
        @parent = args.first
        @opts   = args.extract_options!
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

    def self.parse(view, *args, &block)
      self.new(view, *args).tap do |generator|
        generator.instance_exec(*args, &block)
      end
    end

    def initialize(view, data, opts = {})
      @view = view
      @data = data
      @opts = opts
    end

    attr_reader :view, :opts

    delegate :params, :t, :capture_haml, :haml_tag, to: :@view

    def to_s
      raise "To be implemented"
    end

    def klass
      raise "To be implemented"
    end

  end
end
