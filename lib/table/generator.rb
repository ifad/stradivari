#
# example:
#
# table_for @divisions, { class: 'table-row' } do
#   column :id, sortable: true
#   column :name, { sortable: true, title: "SMILE", class: 'column' }
#   column :acronym, { builder: Table::TextBuilder, sortable: true }
#   column :result, { title: "Result"} do |object|
#     "#{object.id ^ 2}"
#   end
#   column :actions, actions: [:show, :edit, :delete], class: "test"
# end
#
module Table
  class Generator < ::Base::Generator

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
      def initialize(parent, name, opts, renderer)
        @parent   = parent
        @name     = name
        @opts     = opts
        @renderer = renderer
      end

      attr_reader :opts, :name

      def title
        case t = @opts[:title]
        when nil
          klass.human_attribute_name(@name)
        when Proc
          t.call
        when false
          ""
        else
          t
        end
      end

      def to_s object, format=:html
        value = if @renderer.present?
          capture_haml { view.instance_exec(object, &@renderer) }
        else
          build(object)
        end

        case format
        when :html
          force_presence(value)
        else
          value
        end
      end

      def header
        lambda do |col, sort|
          haml_tag :i, '', class: col.sortable_class(sort) if col.sortable?
          haml_concat col.title
        end
      end

      def sortable?
        @opts[:sortable].present?
      end

      def sortable
        if (s = @opts[:sortable]).class.in?([String, Symbol])
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
          klass = if (b = @opts[:builder]).present?
            b
          else
            case type
            when :integer
              Table::NumberBuilder
            when :date
              Table::DateBuilder
            when :datetime
              Table::DateBuilder
            when :boolean
              Table::BooleanBuilder
            else
              Table::TextBuilder
            end
          end

          view.instance_exec(object, @name, @opts, &klass.render)
        end

        def type
          object_columns_hash = klass.try(:extra_columns_hash) || klass.columns_hash

          object_columns_hash.fetch(@name.to_s, nil).try(:type)
        end
    end


    def initialize(*)
      super

      @columns = []

      @opts.reverse_merge! Table::Generator::TABLE_OPTIONS
    end

    def column attr, opts = {}, &renderer
      attr = attr.to_sym

      opts.merge!(builder: Table::ActionBuilder) if attr == :actions

      @columns << Column.new(self, attr, opts, renderer)
    end

    def columns *columns
      opts = columns.extract_options!

      columns.map { |col| column(col, opts)}
    end

    def to_s
      renderer = case @opts[:format]
      when :html
        lambda { @data.present? ? generate_table : generate_no_data }
      when :csv
        lambda { render_csv_content }
      end

      capture_haml(&renderer)
    end

    def klass
      @klass ||= @data.try(:klass) || @data.try(:first).class
    end

    protected

      def render_csv_content
        CSV.generate do |csv|
          csv << render_file_header

          @data.map do |object|
            csv << render_file_row(object)
          end
        end
      end

      def render_file_header
        @columns.map(&:title)
      end

      def render_file_row object
        @columns.map{ |col| col.to_s(object) }
      end

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
              sort = @opts[:sortable]
              haml_tag :th, col.html_opts(sort) do
                @view.instance_exec(col, sort, &col.header)
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
