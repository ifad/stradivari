# frozen_string_literal: true

module Stradivari
  module Table
    class Generator < Stradivari::Generator
      TABLE_OPTIONS = {
        class: 'table table-hover table--stradivari',
        format: :html,
        no_data: 'There is no data.',

        header_visible: true,
        body_visible: true,
        footer_visible: true
      }

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
                    capture_haml { view.instance_exec(object, &@renderer) }
                  else
                    build(object)
                  end

          force_presence(value)
        end

        def header
          sortable_icon if sortable?
          haml_concat title
        end

        def html_opts
          @html_opts ||= @opts.fetch(:html, {}).tap do |html_opts|
            html_opts[:class] = html_opts.fetch(:class, name)

            if sortable?
              html_opts[:class] = [html_opts[:class], 'sortable'].join(' ')
              html_opts[:data] ||= {}
              html_opts[:data][:sort]      = sort_on
              html_opts[:data][:direction] = if sorting_active?
                                               html_opts[:class] << ' active-column'
                                               current_sorting_direction == 'asc' ? 'desc' : 'asc' # Inversion on click
                                             else
                                               'asc'
                                             end
            end

            html_opts[:class] = [html_opts[:class], 'action-builder'].join(' ') if name == :actions # FIXME: REMOVE
          end
        end

        protected

        def build(object)
          view.instance_exec(object, @name, @opts, &builder.render)
        end

        private

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
          klass = +'fas fa-sort'
          fa_icon = "-#{opts[:sortable_icon]}" if opts.key?(:sortable_icon)
          icon_direction =
            if current_sorting_direction == 'asc'
              'down'
            elsif opts.key?(:sortable_icon)
              'down-alt'
            else
              'up'
            end

          klass << "#{fa_icon}-#{icon_direction}" if sorting_active?

          haml_tag :span, '', class: klass
        end
      end

      def initialize(view, rows, *pass, &definition)
        @columns = []

        super(view, rows, *pass)
        opts.reverse_merge! Stradivari::Table::Generator::TABLE_OPTIONS

        instance_exec(rows, *pass, &definition)
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

        capture_haml(&renderer)
      end

      def klass
        @klass ||= @data.respond_to?(:klass) ? @data.klass : @data.try(:first).class
      end

      protected

      def generate_table
        html_opts         = @opts[:html].presence || {}
        html_opts[:class] = [TABLE_OPTIONS[:class], @opts[:class]].uniq.join(' ')
        html_opts[:name]  = @opts[:name]
        html_opts[:id]    = @opts[:id]

        haml_tag :table, html_opts do
          render_header if @opts[:header_visible]
          render_body   if @opts[:body_visible]
          render_footer if @opts[:footer_visible]
        end
      end

      def generate_no_data
        if @no_data
          haml_tag :div, class: 'no-data alert alert-warning', &@no_data
        else
          haml_tag :div, @opts[:no_data], class: 'no-data alert alert-warning'
        end
      end

      def render_header
        haml_tag :thead do
          haml_tag :tr do
            @columns.each do |col|
              haml_tag(:th, col.html_opts) { col.header }
            end
          end
        end
      end

      def render_body
        haml_tag :tbody do
          @data.each do |object|
            if children = self.children(object)
              render_row(object, :parent)

              children.each do |child|
                render_row(child, :child)
              end
            else
              render_row(object)
            end
          end
        end
      end

      def children(object)
        if @opts[:child_method] && (children = object.send(@opts[:child_method])).present?
          children
        end
      end

      def render_row(object, klass = nil)
        attributes = {}.tap do |attributes|
          attributes[:class] = klass
          attributes[:id] = "#{object.class.name.underscore}_row_#{object.id}"
          @row&.call(attributes, object) # allow developer to add custom attributes to the <tr>
        end

        haml_tag :tr, attributes do
          @columns.each do |col|
            haml_tag(:td, col.to_s(object), col.html_opts)
          end
        end
      end

      def render_footer
        haml_tag :tfoot do
          haml_tag :tr do
            haml_tag :td, colspan: @columns.count do
              haml_tag :div, class: 'd-flex justify-content-between align-items-center' do
                haml_concat download if @opts[:downloadable]

                if @custom_footer
                  haml_tag :div, class: @custom_footer[:class].to_s do
                    @view.instance_exec(&@custom_footer[:block])
                  end
                end

                haml_tag :div, counters, class: 'stradivari-counters' if data.respond_to?(:current_page)
              end
            end
          end
        end
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
          "1 to #{@data.limit_value > @data.total_count ? @data.total_count : @data.limit_value} out of #{@data.total_count} records displayed"
        when num_pages
          "#{(@data.current_page - 1) * @data.limit_value + 1} to #{@data.total_count} out of #{@data.total_count} records displayed"
        else
          "#{(@data.current_page - 1) * @data.limit_value + 1} to #{@data.current_page * @data.limit_value} out of #{@data.total_count} records displayed"
        end
      end

      def download
        capture_haml do
          format = @opts[:downloadable] === true ? :csv : @opts[:downloadable]
          classes = +'btn btn-secondary '
          classes << 'stradivari-downloadable-event' if @opts[:downloadable_type] == :event

          text = +' Export'
          case format
          when :csv  then text << ' to CSV'
          when :xlsx then text << ' to Excel'
          end

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

          haml_tag :a, href: view.url_for(params.merge(format: format)), class: classes do
            haml_tag :span, '', class: 'fas fa-file-export', 'aria-hidden' => 'true'
            haml_concat text
          end
        end
      end
    end
  end
end
