module Stradivari
  module Table
    class Generator < Stradivari::Generator

      TABLE_OPTIONS = {
        class: "table table-hover",
        format: :html,
        no_data: "There is no data.",
        header_visible: true,
        body_visible: true,
        footer_visible: true,
        table_row: {
          class: ""
        },
        children_row: {
          parent_class: 'parent-row',
          child_class: 'child-row',
          free_class: 'free-row'
        }
      }

      class Column < Tag
        include Stradivari::Concerns::TableBuilder

        def initialize(parent, name, opts, renderer)
          super(parent, opts)

          @name     = name
          @renderer = renderer
        end

        attr_reader :opts, :name

        def title
          case t = @opts[:title]
          when nil
            klass.human_attribute_name(@name)
          when Proc
            view.instance_eval(&t)
          when false
            ""
          else
            t
          end
        end

        def to_s object
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
          @opts.fetch(:html, {}).tap do |html_opts|
            if sortable?
              html_opts[:class] = "#{html_opts[:class]} sortable"
              html_opts[:data] ||= {}
              html_opts[:data][:sort]      = sort_on
              html_opts[:data][:direction] = if sorting_active?
                html_opts[:class] << " active-column"
                current_sorting_direction == 'asc' ? 'desc' : 'asc' # Inversion on click
              else
                'asc'
              end
            end
          end
        end

        protected
          def build object
            return if !valid?(object)
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
            klass = "fa fa-sort".tap do |s_class|
              if sorting_active?
                s_class << "-#{current_sorting_direction}"
              end
            end

            haml_tag :i, '', class: klass
          end
      end

      def initialize(view, rows, *pass, &definition)
        @columns = []

        super(view, rows, *pass)
        opts.reverse_merge! Stradivari::Table::Generator::TABLE_OPTIONS

        instance_exec(rows, *pass, &definition)
      end

      def column(*args, &renderer)
        opts, attr = args.extract_options!, args.first

        if attr == :actions
          opts.merge!(builder: Stradivari::Table::Builder::ActionBuilder)
        end

        @columns << Column.new(self, attr, opts, renderer)
      end

      def columns(*columns)
        opts = columns.extract_options!

        columns.map {|col| column(col, opts)}
      end

      def to_s
        renderer = lambda { @data.present? ? generate_table : generate_no_data }

        capture_haml(&renderer)
      end

      def klass
        @klass ||= @data.try(:klass) || @data.try(:first).class
      end

      protected
        def generate_table
          html_opts         = @opts[:html].presence || {}
          html_opts[:class] = [ TABLE_OPTIONS[:class], @opts[:class] ].join(' ')
          html_opts[:name]  = @opts[:name]

          haml_tag :table, html_opts do
            render_header if @opts[:header_visible]
            render_body   if @opts[:body_visible]
            render_footer if @opts[:footer_visible]
          end
        end

        def generate_no_data
          haml_tag :div, @opts[:no_data], class: 'no-data alert alert-warning'
        end

        def render_header
          haml_tag :thead do
            haml_tag :tr do
              @columns.each do |col|
                haml_tag :th, col.html_opts do
                  col.header
                end
              end
            end
          end
        end

        def render_body
          haml_tag :tbody do
            @data.each do |object|
              haml_tag :tr, id: "#{object.class.model_name.to_s.underscore}_row_#{object.id}" do
                @columns.each do |col|
                  html = col.opts[:html].presence || {}

                  html[:class] = "#{html[:class]} #{col.name} #{'action-builder' if col.name == :actions}"

                  haml_tag(:td, col.to_s(object), html)
                end
              end
            end
          end
        end

        def render_footer
          if @data.is_a?(ActiveRecord::Relation) &&
             @data.respond_to?(:current_page)

            haml_tag :tfoot do
              haml_tag :tr do
                haml_tag :td, colspan: @columns.count do
                  haml_tag :div, download, class: 'download pull-left' if @opts[:downloadable]
                  haml_tag :div, counters, class: 'counters pull-right'
                  haml_tag :div, '', class: 'clearfix'
                end
              end
            end
          end
        end

        def counters
          case @data.current_page
          when 1
            "1 to #{@data.limit_value > @data.total_count ? @data.total_count : @data.limit_value} out of #{@data.total_count} records displayed"
          when @data.num_pages
            "#{(@data.current_page - 1) * (@data.limit_value) + 1} to #{@data.total_count} out of #{@data.total_count} records displayed"
          else
            "#{(@data.current_page - 1) * (@data.limit_value) + 1} to #{@data.current_page * (@data.limit_value)} out of #{@data.total_count} records displayed"
          end
        end

        def download
          capture_haml do
            haml_tag :a, 'Download...', href: view.url_for(view.params.merge(format: :csv))
          end
        end

    end
  end
end
