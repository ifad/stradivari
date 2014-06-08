module Filter

  class Generator < ::Base::Generator
    NAMESPACE = Filter::NAMESPACE

    FILTER_OPTIONS = {
      detached: false,
      inline: false,
      class: 'filter-form-container ',
      id:    'filter-form'
    }

    class Field < Tag
      def initialize(parent, scope, name, opts)
        @parent = parent
        @scope  = scope
        @name   = name
        @opts   = opts.merge(
          namespace: NAMESPACE,
          is_column: klass.columns_hash[@name.to_s].present?,
          is_scoped: klass._ransackers[@name.to_s].present?
        )
      end

      def active?
        active = case @scope
        when :number_field
          [ ns[@name], ns["#{@name}_eq"], ns["#{@name}_lt"], ns["#{@name}_gt"] ]
        when :selection_field
          [ ns[@name], ns["#{@name}_eq"] ]
        when :date_range_field
          [ ns[@name], ns["#{@name}_gteq"], ns["#{@name}_lteq"] ]
        when :boolean_field
          [ ns[@name], ns["#{@name}_eq"] ]
        when :checkbox_field
          [ ns[@name], ns["#{@name}_in"] ]
        else
          [ ns[@name], ns["#{@name}_cont"] ]
        end

        active.map(&:present?).any?
      end

      def to_s
        build
      end

      protected

        def ns
          @parent.opts[NAMESPACE]
        end

        def build
          value = ns[@name]

          klass = if (builder = @opts[:builder]).present?
            builder
          else
            case @scope
            when :selection_field
              value = ns[@name] || ns["#{@name}_eq"]

              Filter::SelectionFieldBuilder
            when :date_range_field
              value = [ns["#{@name}_gteq"], ns["#{@name}_lteq"]]

              Filter::DateRangeFieldBuilder
            when :number_field
              value = if ns["#{@name}_lt"].present?
                ["#{@name}_lt", ns["#{@name}_lt"]]
              elsif ns["#{@name}_gt"].present?
                ["#{@name}_gt", ns["#{@name}_gt"]]
              else
                ["#{@name}_eq", ns["#{@name}_eq"]]
              end

              Filter::NumberFieldBuilder
            when :boolean_field
              value = ns[@name] || ns["#{@name}_eq"]

              Filter::BooleanFieldBuilder
            when :checkbox_field
              value = ns["#{@name}_in"] || ns[@scope]

              Filter::CheckboxFieldBuilder
            else
              value = ns[@name] || ns["#{@name}_cont"]

              Filter::SearchFieldBuilder
            end
          end

          view.instance_exec(klass, @name, @opts.merge(value: value), &klass.render)
        end
    end

    def initialize(*)
      super

      @fields = []

      @opts.reverse_merge! Filter::Generator::FILTER_OPTIONS
    end

    def field scope, attr, opts = {}
      attr  = attr.to_sym
      scope = scope.to_sym

      @fields << Field.new(self, scope, attr, opts)
    end

    %w[search selection date_range boolean checkbox number].each do |scope|
      define_method "#{scope}_field" do |attr, opts = {}|
        field "#{scope}_field", attr, opts
      end
    end

    def to_s
      renderer = lambda do
        id = @opts.fetch(:id, "filter_fields_for_#{ActiveModel::Naming.singular(klass)}")
        form_classes = 'filter-form '
        form_classes << 'form-inline '   if inline?
        form_classes << 'detached-form ' if detached?

        capture_haml do
          haml_tag :div, class: @opts[:class] do

            id, link = id, [ id, 'detached' ].join('_')
            id, link = link, id if detached?

            haml_tag :form, class: form_classes, role: 'form', id: id, data: { link: link } do
              haml_tag :input, type: :hidden, name: :sort,      value: params[:sort]
              haml_tag :input, type: :hidden, name: :direction, value: params[:direction]

              haml_tag :div, class: (detached? ? '' : 'panel panel-info') do
                generate_actions if !detached? && @fields.count > 5

                generate_custom_block(@prepended) if !detached? && @prepended.present?
                generate_active_fields
                generate_inactive_fields
                generate_custom_block(@appended) if !detached? && @appended.present?
                generate_actions if !detached?
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

      def detached?
        !!@opts.fetch(:detached, nil)
      end

      def inline?
        !!@opts.fetch(:inline, nil)
      end

      def generate_active_fields
        if (active_fields = @fields.select(&:active?)).count > 0
          haml_tag :div, class: (detached? ? '' : 'panel-heading') do
            active_fields.each(&:to_s)
          end
        end
      end

      def generate_inactive_fields
        if (inactive_fields = @fields.reject(&:active?)).count > 0
          haml_tag :div, class: (detached? ? '' : 'panel-body') do
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
        @view.instance_exec(&Filter::ActionFieldBuilder.render)
      end

  end
end
