module Stradivari
  module Filter

    class Generator < Stradivari::Generator
      NAMESPACE = Filter::NAMESPACE

      FILTER_OPTIONS = {
        detached: false,
        inline: false,
        class: 'filter-form-container ',
        id:    'filter-form'
      }

      class Field < Tag
        def initialize(parent, scope, name, opts, &renderer)
          super(parent, opts)

          @scope    = scope
          @name     = name
          @active   = if (active_block = @opts.fetch(:active, nil))
            view.instance_exec(&active_block)
          else
            false
          end

          if renderer.present?
            raise ArgumentError, "To use custom field you need to provide active attribute block inside options" unless opts.has_key?(:active)
            @renderer = renderer
          end

          @opts.merge!(
            namespace: NAMESPACE,
            is_scoped: klass.stradivari_scopes[@name.to_sym].present?
          )
        end

        def active?
          @active || builder.active?(params, @name)
        end

        def value
          builder.value(params, @name)
        end

        def to_s
          render_block = @renderer.present? ? @renderer : builder.render
          view.instance_exec(@name, @opts.merge(value: value, active_field: active?), &render_block)
        end

        protected
          def builder
            @_bulder ||= @opts[:builder] || Builder::Implementations.fetch(@scope)
          end

          def params
            @parent.params[NAMESPACE] || {}
          end
      end

      def initialize(view, klass, *pass, &definition)
        @fields = []

        super(view, klass, *pass)
        opts.reverse_merge! Filter::Generator::FILTER_OPTIONS
        opts[:inline] = true if detached?

        instance_exec(*pass, &definition)
      end

      def field scope, attr, opts = {}, &renderer
        attr  = attr.to_sym
        scope = scope.to_sym

        if (f = self.class.const_get(:Field).new(self, scope, attr, opts, &renderer)).enabled?
          @fields << f
        end
      end

      Builder::Implementations.each do |name, _|
        define_method name do |attr, opts = {}, &renderer|
          field(name, attr, opts, &renderer)
        end
      end

      def to_s
        renderer = lambda do
          id = @opts.fetch(:id, "filter_fields_for_#{klass.name.singularize.underscore}")
          form_classes = 'filter-form '
          form_classes << 'form-detached ' if detached?

          capture_haml do
            haml_tag :div, class: @opts[:class] do

              id, link = id, [ id, 'detached' ].join('_')
              id, link = link, id if detached?

              data = { link: link }
              data[:detached] = "true" if detached?

              haml_tag :form, class: form_classes, role: 'form', id: id, data: data do
                unless detached?
                  haml_tag :input, type: :hidden, name: :sort,      value: @opts.fetch(:sort,      view.params[:sort])
                  haml_tag :input, type: :hidden, name: :direction, value: @opts.fetch(:direction, view.params[:direction])
                end

                wrapping do
                  generate_actions if !inline? && @fields.count > 5

                  generate_custom_block(@prepended) if !detached? && @prepended.present?
                  generate_active_fields
                  generate_inactive_fields
                  generate_custom_block(@appended) if !detached? && @appended.present?
                  generate_actions if !inline?
                end
              end
            end
          end
        end

        capture_haml(&renderer)
      end

      def prepend opts = {}, &block
        @prepended = opts.merge(block: block)
      end

      def append opts = {}, &block
        @appended = opts.merge(block: block)
      end

      def klass
        @data
      end

      protected

        def wrapping(&block)
          if inline?
            block.call
          else
            haml_tag :div, class: 'panel panel-info', &block
          end
        end

        def detached?
          !!@opts.fetch(:detached, nil)
        end

        def inline?
          !!@opts.fetch(:inline, nil)
        end

        def generate_active_fields
          if (active_fields = @fields.select(&:active?)).count > 0
            haml_tag :div, class: (inline? ? '' : 'panel-heading') do
              active_fields.each(&:to_s)
            end
          end
        end

        def generate_inactive_fields
          if (inactive_fields = @fields.reject(&:active?)).count > 0
            haml_tag :div, class: (inline? ? '' : 'panel-body') do
              inactive_fields.each(&:to_s)
            end
          end
        end

        def generate_custom_block(opts)
          haml_tag :div, class: "panel-body #{opts[:class] || 'custom'}" do
            @view.instance_exec(&opts[:block])
          end
        end

        def generate_actions
          @view.instance_exec(&Filter::Builder::ActionField.render)
        end

    end
  end
end
