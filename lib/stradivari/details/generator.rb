module Stradivari
  module Details

    class Generator < Stradivari::Generator

      DETAILS_OPTIONS = {
        class: 'dl-horizontal'
      }

      class Field < Tag
        include Stradivari::Concerns::TableBuilder

        attr_reader :renderer

        def initialize(parent, label, opts, renderer)
          super(parent, opts)

          @label    = label
          @renderer = renderer

          @opts.reverse_merge!(label: {}, content: {})
        end

        def label
          @opts[:title].presence || klass.human_attribute_name(@label)
        end

        def content
          force_presence(value)
        end

        protected
          delegate :object, to: :@parent

          def value(object = self.object)
            if @renderer.present?
              capture_haml { view.instance_exec(object, &@renderer) }
            else
              build
            end
          end

          def build
            view.instance_exec(object, @opts[:method].presence || @label, @opts, &builder.render)
          end

          def name
            @label
          end
      end

      def initialize(view, object, *pass, &definition)
        @fields = []

        super(view, object, *pass)
        opts.reverse_merge! Details::Generator::DETAILS_OPTIONS

        instance_exec(object, *pass, &definition)
      end

      alias object data

      def field(label, opts = {}, &renderer)
        if (f = self.class.const_get(:Field).new(self, label, opts, renderer)).enabled?
          @fields << f
        end
      end

      def to_s
        renderer = lambda do
          haml_tag :dl, @opts do
            @fields.each do |field|
              if (c = field.content).present?
                haml_tag :dt, field.label, field.opts[:label]
                haml_tag :dd, c,           field.opts[:content]
              end
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
end
