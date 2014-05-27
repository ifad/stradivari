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
#   column_actions actions: [:show, :edit, :delete], class: "test"
# end
#
module Table
  class Generator
    include Haml::Helpers
    include ActionView::Context
    include Kaminari::ActionViewExtension
    include Kaminari::Helpers
    include ActionView::Helpers::UrlHelper
    # include ActionView::AssetPaths
    include Sprockets::Rails::Helper
    include ActiveSupport::Inflector
    include ActionView::Helpers::AssetTagHelper
    include ActionController::UrlFor
    include Rails.application.routes.url_helpers
    include Rails.application.helpers
    include ActionView::Helpers::TextHelper

    attr_accessor :data, :options, :column_order, :haml_buffer

    DEFAULT_TABLE_OPTIONS = {
      class: "table table-hover",
      format: :html,
      no_data: "There is no data.",
      header_visible: true,
      body_visible:   true,
      footer_visible: true,
      table_row: {
        class: ""
      },
      children_row_html: {
        parent_class: 'parent-row',
        child_class: 'child-row',
        free_class: 'free-row'
      }
    }

    DEFAULT_COLUMN_OPTIONS = {
      options: {}
    }

    DEFAULT_COLUMN_ROW_OPTIONS = {
      options: {}
    }

    class << self
      def generate_table_for data = [], options = {}, &block
        new.table_for data, options, &block
      end

      def generate_csv_for data = [], options = {}, &block
        new.csv_for data, options, &block
      end
    end

    def initialize
      @columns = {}
      @column_order = []
    end

    def table_for data, options = {}, &block
      generator_for data, options, &block
    end

    def csv_for data, options = {}, &block
      generator_for data, options.merge(format: :csv), &block
    end

    def column attribute_name, options = {}, &block
      attribute_name = attribute_name.to_sym unless attribute_name.is_a? Symbol

      unless @columns.has_key? attribute_name
        @columns[attribute_name] = {
          options: Table::Generator::DEFAULT_COLUMN_OPTIONS.merge(options),
          block: block
        }
        @column_order << attribute_name
      end
    end

    def columns *columns
      columns.each { |column_name| column(column_name)}
    end

    def column_actions options = {}, &block
      column :actions, options.merge(builder: Table::ActionBuilder), &block
    end

    def to_s
      render
    end

    protected
      def env
        controller.env
      end

      def controller
        @options[:controller] || ApplicationController
      end

      def column_title column_name
        case title = @columns[column_name][:options][:title]
        when nil
          column_name.to_s.titleize
        when Proc
          title.call
        when false
          ""
        else
          title
        end
      end

      def render
        case @options[:format]
        when :html
          @data.present? ? generate_table : generate_no_data
        when :csv
          render_csv_content
        end
      end

      def render_csv_content
        wrapping do
          CSV.generate do |csv|
            csv << render_file_header

            @data.each do |object|
              csv << render_file_row(object)
            end
          end
        end
      end

      def render_file_header
        file_render_columns.map do |column_name|
          column_title(column_name)
        end
      end

      def render_file_row object
        file_render_columns.map do |attribute_name|
          generate_column(object, attribute_name)
        end
      end

      def file_render_columns
        @column_order.reject { |attribute_name|
          c = @columns[attribute_name]

          c[:options][:skip_file_generation].presence || attribute_name == :actions
        }
      end

      def generate_table
        wrapping do
          html_options         = @options[:html].presence || {}
          html_options[:class] = [ DEFAULT_TABLE_OPTIONS[:class], @options[:class] ].join(' ')
          html_options[:name]  = @options[:name]

          haml_tag :table, html_options  do
            render_header if @options[:header_visible]
            render_body   if @options[:body_visible]
            render_footer if @options[:footer_visible]
          end

          # TODO override url helpers
          # generate_pagination
        end
      end

      def generate_no_data
        wrapping do
          haml_tag :div, @options[:no_data], class: 'no-data alert alert-warning'
        end
      end

      def wrapping(&block)
        init_haml_helpers
        capture_haml(&block)
      end

      def generate_pagination
        if Gem::Specification::find_all_by_name('kaminari').any?
          controller = ActionController::Base.new
          controller.request = ActionDispatch::Request.new(@options[:env])
          ActionView::Base.send(:include, Rails.application.routes.url_helpers)
          view = ActionView::Base.new(Kaminari::Engine.paths['app/views'].first, {}, controller)

          options = {
            current_page: @data.current_page,
            total_pages: @data.total_pages,
            per_page: @data.limit_value,
            param_name: Kaminari.config.param_name,
            remote: false
          }
          paginator = Kaminari::Helpers::Paginator.new(view, options)
          haml_concat paginator.to_s
        end
      end

      def render_header
        haml_tag :thead do
          haml_tag :tr do
            @column_order.each do |column_name|
              title    = column_title(column_name)
              classes  = ""
              s_class  = "fa fa-sort"
              data     = {}
              sortable = @columns[column_name][:options][:sortable]

              if sortable.present?
                classes << " sortable"

                data[:sort] = if sortable.class.in?([String, Symbol])
                  sortable.to_s
                else
                  column_name
                end

                if @sortable[:sort].in?([column_name, sortable].map(&:to_s))
                  classes << " active-column"
                  s_class << "-#{@sortable[:direction]}"

                  data[:direction] = @sortable[:direction] == 'asc' ? 'desc' : 'asc' # Inversion on click
                else
                  data[:direction] = 'asc'
                end
              end

              html_options = {
                class: classes,
                data: data
              }

              if (html = @columns[column_name][:options][:html]).present?
                html_options.merge! html
              end

              unless column_name.in?([:select, :checkbox, :actions])
                html_options[:class] = "#{html_options[:class]} #{column_name} "
              end

              haml_tag :td, html_options do
                haml_tag :i, '', class: s_class if sortable.present?

                haml_concat title
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
              haml_tag :td, colspan: @column_order.count do
                haml_tag :div, download, class: 'download pull-left' if @options[:downloadable]
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
          haml_tag :a, 'Download...', href: url_for(params.merge(format: :csv))
        end
      end

      def render_body
        haml_tag :tbody do
          @data.each do |object|
            if @options[:children_rows].present?
              render_row_with_children(object)
            else
              render_row object
            end
          end
        end
      end

      def render_row_with_children parent
        if (children = parent.public_send(@options[:children_rows])).present?
          render_row parent, class: @options[:children_row_html][:parent_class]

          children.each do |child|
            render_row child, class: @options[:children_row_html][:child_class]
          end
        else
          render_row parent, class: @options[:children_row_html][:free_class]
        end
      end

      def render_row object, row_options = {}
        classes = "#{@options[:table_row][:class]} #{row_options[:class]}".strip
        html_id = "#{object.class.model_name.to_s.underscore}_row_#{object.id}"

        haml_tag :tr, class: classes, id: html_id do
          @column_order.each do |attribute_name|
            generate_column(object, attribute_name)
          end
        end
      end

      def generate_column object, attribute_name
        block   = @columns[attribute_name][:block]
        options = @columns[attribute_name][:options][:html].presence || {}

        options[:class] = "#{options[:class]} #{attribute_name}"
        options[:class] = "#{options[:class]} action-builder" if attribute_name == :actions

        begin
          value = if block.present?
            capture_haml(object, &block)
          else
            process_builder(object, attribute_name)
          end

          @options[:format] == :html ? haml_tag(:td, value, options) : value
        rescue
          raise ArgumentError, "Provided attribute name does not exist on the model, if you want to have custom field define block or new builder and add builder class in options for that column"
        end
      end

      def process_builder object, attribute_name
        klass = if @columns[attribute_name][:options][:builder].present?
          @columns[attribute_name][:options][:builder]
        else
          case object_attribute_type object, attribute_name
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

        klass.generate_field(object, attribute_name, @columns[attribute_name][:options])
      end

      def object_columns_hash object
        klass = object.class

        klass.try(:extra_columns_hash) || klass.columns_hash
      end

      def object_has_attribute? object, attribute_name
        object_columns_hash(object).key?(attribute_name.to_s)
      end

      def object_attribute_type object, attribute_name
        if object_has_attribute? object, attribute_name
          object_columns_hash(object).fetch(attribute_name.to_s).type
        end
      end

      def generator_for data, options = {}, &block
        @data     = data
        @options  = Table::Generator::DEFAULT_TABLE_OPTIONS.merge(options)
        @sortable = options[:sortable]

        extend controller._helpers

        # The force option always evaluates the block even if there is no data
        # present. In some cases table renderers are re-used, like in
        # registrations_helper, and it may happen that the first dataset is
        # empty but successive ones are filled.
        #
        # Given that the columns definition is lazily evaluated by the block
        # itself, if we don't force then no row would be rendered for the
        # subsequent datasets.
        instance_eval(&block) if block.present? && (@data.present? || @options[:force])

        self
      end

      def method_missing name, *args, &block
        controller.view_context.send(name, *args)
      end

  end
end
