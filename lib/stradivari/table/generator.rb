module Stradivari
  module Table
    class Generator < Stradivari::Generator
      TABLE_OPTIONS = {
        class: 'stradivari-table stradivari-table--hover',
        format: :html,
        no_data: 'There is no data.',

        header_visible: true,
        body_visible: true,
        footer_visible: true
      }.freeze

      class Column < Tag
        include Stradivari::Concerns::TableBuilder

        def initialize(parent, name, opts, renderer)
          super(parent, opts)

          @name     = name
          @renderer = renderer
        end

        attr_reader :opts, :name

        def to_s(object)
          value = if @renderer.present?
                    capture { view.instance_exec(object, &@renderer) }
                  else
                    build(object)
                  end

          force_presence(value)
        end

        def header
          concat sortable_icon if sortable?
          concat title
        end

        def header_html_opts
          @header_html_opts ||= base_html_opts.tap do |html_opts|
            classes = ['stradivari-table__header-cell', html_opts[:class]]

            if sortable?
              classes << 'stradivari-table__header-cell--sortable'
              html_opts[:data] ||= {}
              html_opts[:data][:stradivari_table_sort] = true
              html_opts[:data][:sort]      = sort_on
              html_opts[:data][:direction] = if sorting_active?
                                               classes << 'stradivari-table__header-cell--active'
                                               current_sorting_direction == 'asc' ? 'desc' : 'asc' # Inversion on click
                                             else
                                               'asc'
                                             end
            end

            classes << 'stradivari-table__header-cell--actions' if name == :actions
            html_opts[:class] = Stradivari::ClassNames.join(classes)
          end
        end

        def cell_html_opts
          @cell_html_opts ||= base_html_opts.tap do |html_opts|
            html_opts[:class] = Stradivari::ClassNames.join(
              'stradivari-table__cell',
              html_opts[:class],
              Stradivari::ClassNames.modifier('stradivari-table__cell', :actions, enabled: name == :actions)
            )
          end
        end

        def html_opts
          header_html_opts
        end

        protected

        def build(object)
          view.instance_exec(object, @name, @opts, &builder.render)
        end

        private

        def base_html_opts
          @opts.fetch(:html, {}).deep_dup.tap do |html_opts|
            html_opts[:class] = html_opts.fetch(:class, name)
          end
        end

        def sortable?
          opts.key?(:sortable)
        end

        def current_sorting_column
          view.sortable[:sort].to_s
        end

        def current_sorting_direction
          view.sortable[:direction].to_s
        end

        def sorting_active?
          current_sorting_column == sort_on
        end

        def sort_on
          ((s = opts[:sortable]) === true ? @name : s).to_s
        end

        def sortable_icon
          icon = sorting_active? ? "sort_#{current_sorting_direction}" : :sort

          Stradivari::Icons.svg(icon)
        end
      end

      def initialize(view, rows, *pass, &)
        @columns = []

        super(view, rows, *pass)
        opts.reverse_merge! Stradivari::Table::Generator::TABLE_OPTIONS

        instance_exec(rows, *pass, &)
      end

      def row(&block)
        @row = block
      end

      def no_data(&block)
        @no_data = block
      end

      def column(*args, &renderer)
        opts = args.extract_options!
        attr = args.first

        opts[:builder] = Stradivari::Table::Builder::ActionBuilder if attr == :actions

        if (c = self.class.const_get(:Column).new(self, attr, opts, renderer)).enabled?
          @columns << c
        end
      end

      def columns(*columns)
        opts = columns.extract_options!

        columns.map { |col| column(col, opts) }
      end

      def footer(opts = {}, &block)
        @custom_footer = opts.merge(block: block)
      end

      def to_s
        renderer = -> { @data.present? ? generate_table : generate_no_data }

        capture(&renderer)
      end

      def klass
        @klass ||= @data.respond_to?(:klass) ? @data.klass : @data.try(:first).class
      end

      protected

      def generate_table
        html_opts         = (@opts[:html].presence || {}).deep_dup
        html_opts[:class] = Stradivari::ClassNames.join(TABLE_OPTIONS[:class], @opts[:class], html_opts[:class])
        html_opts[:name]  = @opts[:name]
        html_opts[:id]    = @opts[:id]
        html_opts[:data]  = (html_opts[:data] || {}).merge(stradivari_table: true)

        concat(
          content_tag(:table, html_opts) do
            render_header if @opts[:header_visible]
            render_body   if @opts[:body_visible]
            render_footer if @opts[:footer_visible]
          end
        )
      end

      def generate_no_data
        if @no_data
          concat(content_tag(:div, class: 'stradivari-table__empty', &@no_data))
        else
          concat content_tag(:div, @opts[:no_data], class: 'stradivari-table__empty')
        end
      end

      def render_header
        concat(
          content_tag(:thead) do
            concat(
              content_tag(:tr) do
                @columns.each do |col|
                  concat(content_tag(:th, col.header_html_opts) { col.header })
                end
              end
            )
          end
        )
      end

      def render_body
        concat(
          content_tag(:tbody) do
            @data.each do |object|
              if (children = self.children(object))
                render_row(object, :parent)

                children.each do |child|
                  render_row(child, :child)
                end
              else
                render_row(object)
              end
            end
          end
        )
      end

      def children(object)
        return unless @opts[:child_method] && (children = object.send(@opts[:child_method])).present?

        children
      end

      def render_row(object, klass = nil)
        attributes = {}.tap do |attributes|
          attributes[:class] = Stradivari::ClassNames.modifier('stradivari-table__row', klass) if klass
          attributes[:id] = "#{object.class.name.underscore}_row_#{object.id}"
          @row&.call(attributes, object) # allow developer to add custom attributes to the <tr>
        end

        concat(
          content_tag(:tr, attributes) do
            @columns.each do |col|
              concat content_tag(:td, col.to_s(object), col.cell_html_opts)
            end
          end
        )
      end

      def render_footer
        concat(
          content_tag(:tfoot) do
            concat(
              content_tag(:tr) do
                concat(
                  content_tag(:td, colspan: @columns.count) do
                    concat content_tag(:div, download, class: 'stradivari-table__download') if @opts[:downloadable]

                    if @custom_footer
                      concat(
                        content_tag(:div, class: Stradivari::ClassNames.join('stradivari-table__custom-footer', @custom_footer[:class])) do
                          @view.instance_exec(&@custom_footer[:block])
                        end
                      )
                    end

                    concat content_tag(:div, counters, class: 'stradivari-table__counters') if data.respond_to?(:current_page)
                  end
                )
              end
            )
          end
        )
      end

      def counters
        num_pages =
          if @data.respond_to?(:num_pages)
            @data.num_pages
          elsif @data.respond_to?(:total_pages)
            @data.total_pages
          end

        case @data.current_page
        when 1
          "1 to #{[@data.limit_value, @data.total_count].min} out of #{@data.total_count} records displayed"
        when num_pages
          "#{((@data.current_page - 1) * @data.limit_value) + 1} to #{@data.total_count} out of #{@data.total_count} records displayed"
        else
          "#{((@data.current_page - 1) * @data.limit_value) + 1} to #{@data.current_page * @data.limit_value} out of #{@data.total_count} records displayed"
        end
      end

      def download
        capture do
          format = @opts[:downloadable] === true ? :csv : @opts[:downloadable]
          data = {}
          data[:stradivari_table_download] = 'event' if @opts[:downloadable_type] == :event

          text = 'Export'
          case format
          when :csv  then text << ' to CSV'
          when :xlsx then text << ' to Excel'
          end
          text << '...'

          params = view.params.dup
          params = params.permit! if params.respond_to?(:permit!)
          params = params.to_h

          # Work around url_for() below not yielding in the resulting query
          # string Array parameters that are empty.
          #
          #   url_for(foo: []) => /
          #   url_for(foo: ['']) => /?foo[]=
          #
          # This is necessary to discern between "array parameter not set"
          # or "array parameter set to empty".
          #
          params[:q]&.tap do |query|
            params[:q] = query.each { |k, v| query[k] = [''] if v.is_a?(Array) && v.empty? }
          end

          concat content_tag(:a, text,
                             href: view.url_for(params.merge(format: format)),
                             class: Stradivari::ClassNames.join('stradivari-table__download-link', Stradivari::ClassNames.modifier('stradivari-table__download-link', :event, enabled: data.present?)),
                             data: data)
        end
      end
    end
  end
end
