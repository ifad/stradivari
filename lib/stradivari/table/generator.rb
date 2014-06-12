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
          lambda do |col, sort|
            haml_tag :i, '', class: col.sortable_class(sort) if col.sortable?
            haml_concat col.title
          end
        end

        def sortable?
          view.sortable.present?
        end

        def sortable
          if (s = view.sortable).class.in?([String, Symbol])
            s.to_s
          else
            @name.to_s
          end
        end

        def sortable_class sort
          "fa fa-sort".tap do |s_class|
            if sort[:sort].to_s.in?([@name, sortable].map(&:to_s))
              s_class << "-#{sort[:direction]}"
            end
          end
        end

        def html_opts sort
          { class: "", data: {} }.tap do |html_opts|
            if sortable?
              html_opts[:class] << " sortable"

              html_opts[:data][:sort]      = sortable
              html_opts[:data][:direction] = if sort[:sort].to_s.in?([@name, sortable].map(&:to_s))
                html_opts[:class] << " active-column"

                sort[:direction] == 'asc' ? 'desc' : 'asc' # Inversion on click
              else
                'asc'
              end
            end

            html_opts.merge! @opts.fetch(:html, {})

            unless @name.in?([:select, :checkbox, :actions])
              html_opts[:class] = "#{html_opts[:class]} #{@name} "
            end
          end
        end

        protected
          def build object
            view.instance_exec(object, @name, @opts, &builder.render)
          end
      end


      def initialize(view, data, *args)
        opts = args.extract_options!

        super(view, data, opts)

        @columns = []

        @opts.reverse_merge! Stradivari::Table::Generator::TABLE_OPTIONS
      end

      def column attr, opts = {}, &renderer
        attr = attr.to_sym

        opts.merge!(builder: Stradivari::Table::Builder::ActionBuilder) if attr == :actions

        @columns << Column.new(self, attr, opts, renderer)
      end

      def columns *columns
        opts = columns.extract_options!

        columns.map { |col| column(col, opts)}
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
                haml_tag :th, col.html_opts(@view.sortable) do
                  @view.instance_exec(col, @view.sortable, &col.header)
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
