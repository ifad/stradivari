module Details

  class Generator < Stradivari::Generator

    DETAILS_OPTIONS = {
      class: 'dl-horizontal'
    }

    class Field < Tag
      include Stradivari::Concerns::TableBuilder

      def initialize(parent, object, label, opts, renderer)
        super(parent, opts)

        @object   = object
        @label    = label
        @renderer = renderer

        @opts.reverse_merge!(label: {}, content: {}).merge!(present: true)
      end

      def label
        @opts[:title].presence || klass.human_attribute_name(@label)
      end

      def content
        value = if @renderer.present?
          capture_haml { view.instance_exec(@object, &@renderer) }
        else
          build
        end

        force_presence(value)
      end

      protected
        def build
          view.instance_exec(@object, @opts[:method].presence || @label, @opts, &builder.render)
        end

        def name
          @label
        end
    end

    def initialize(*)
      super

      @fields = []

      @opts.reverse_merge! Details::Generator::DETAILS_OPTIONS
    end

    def field(label, opts = {}, &renderer)
      @fields.push Field.new(self, @data, label, opts, renderer)
    end

    def to_s
      renderer = lambda do
        haml_tag :dl, @opts do
          @fields.each do |field|
            haml_tag :dt, field.label, field.opts[:label]
            haml_tag :dd, field.content, field.opts[:content]
          end
        end
      end

      capture_haml(&renderer)
    end

    def klass
      @data.class
    end

  end
end
