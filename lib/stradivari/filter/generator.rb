module Stradivari
  module Filter
    class Generator < Stradivari::Generator
      NAMESPACE = Filter::NAMESPACE

      FILTER_OPTIONS = {
        detached: false,
        inline: false,
        class: 'stradivari-filter',
        id: 'filter-form'
      }.freeze

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
            raise ArgumentError, 'To use custom field you need to provide active attribute block inside options' unless opts.key?(:active)

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
          render_block = @renderer.presence || builder.render
          rendered = view.capture do
            view.instance_exec(@name, @opts.merge(value: value, active_field: active?), &render_block)
          end
          view.concat rendered
        end

        protected

        def builder
          @builder ||= @opts[:builder] || Builder::Implementations.fetch(@scope)
        end

        def params
          @parent.params[NAMESPACE] || {}
        end
      end

      def initialize(view, klass, *pass, &)
        @fields = []

        super(view, klass, *pass)
        opts.reverse_merge! Filter::Generator::FILTER_OPTIONS
        opts[:inline] = true if detached?

        instance_exec(*pass, &)
      end

      def field(scope, attr, opts = {}, &)
        attr  = attr.to_sym
        scope = scope.to_sym

        if (f = self.class.const_get(:Field).new(self, scope, attr, opts, &)).enabled?
          @fields << f
        end
      end

      Builder::Implementations.each_key do |name|
        define_method name do |attr, opts = {}, &renderer|
          field(name, attr, opts, &renderer)
        end
      end

      def to_s
        renderer = lambda do
          id = @opts.fetch(:id, "filter_fields_for_#{klass.name.singularize.underscore}")
          form_classes = Stradivari::ClassNames.join(
            'stradivari-filter__form',
            Stradivari::ClassNames.modifier('stradivari-filter__form', :detached, enabled: detached?)
          )

          concat(
            content_tag(:div, class: @opts[:class]) do
              link = [id, 'detached'].join('_')
              id, link = link, id if detached?

              data = { link: link, stradivari_filter_form: (detached? ? 'detached' : 'main') }
              unless detached?
                data[:stradivari_filter_context] = Filter::CONTEXT
                data[:stradivari_filter_namespace] = NAMESPACE
              end
              data[:detached] = 'true' if detached?

              concat(
                content_tag(:form, class: form_classes, role: 'form', id: id, data: data) do
                  unless detached?
                    concat tag.input(type: :hidden, name: :sort,      value: @opts.fetch(:sort,      view.params[:sort]))
                    concat tag.input(type: :hidden, name: :direction, value: @opts.fetch(:direction, view.params[:direction]))
                  end

                  wrapping do
                    generate_actions if !inline? && @fields.count > 5

                    generate_custom_block(@prepended) if !detached? && @prepended.present?
                    generate_active_fields
                    generate_inactive_fields
                    generate_custom_block(@appended) if !detached? && @appended.present?
                    generate_actions unless inline?
                  end
                end
              )
            end
          )
        end

        capture(&renderer)
      end

      def prepend(opts = {}, &block)
        @prepended = opts.merge(block: block)
      end

      def append(opts = {}, &block)
        @appended = opts.merge(block: block)
      end

      def klass
        @data
      end

      protected

      def wrapping(&)
        if inline?
          yield
        else
          concat(content_tag(:div, class: 'stradivari-filter__panel', &))
        end
      end

      def detached?
        !!@opts.fetch(:detached, nil)
      end

      def inline?
        !!@opts.fetch(:inline, nil)
      end

      def generate_active_fields
        if (active_fields = @fields.select(&:active?)).any?
          concat(
            content_tag(:div, class: (inline? ? nil : 'stradivari-filter__section stradivari-filter__section--active')) do
              active_fields.each(&:to_s)
            end
          )
        end
      end

      def generate_inactive_fields
        if (inactive_fields = @fields.reject(&:active?)).any?
          concat(
            content_tag(:div, class: (inline? ? nil : 'stradivari-filter__section stradivari-filter__section--inactive')) do
              inactive_fields.each(&:to_s)
            end
          )
        end
      end

      def generate_custom_block(opts)
        concat(
          content_tag(:div, class: Stradivari::ClassNames.join('stradivari-filter__section stradivari-filter__section--custom', opts[:class])) do
            @view.instance_exec(&opts[:block])
          end
        )
      end

      def generate_actions
        @view.instance_exec(&Filter::Builder::ActionField.render)
      end
    end
  end
end
