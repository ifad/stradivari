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

    def controller
      @options[:controller] || ApplicationController
    end

    def request
      controller.request
    end

    def env
      controller.env
    end

    def self.generate_table_for data = [], options = {}, &block
      new.table_for data, options, &block
    end

    def initialize
      @columns = {}
      @column_order = []
    end

    def table_for data, options = {}, &block
      @data = data
      @options = Table::Generator::DEFAULT_TABLE_OPTIONS.merge(options)
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
      instance_eval &block if block.present? && (@data.present? || @options[:force])

      self
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
      column :actions, options, &block
    end

    def column_row options = {}

    end

    def render
      if @data.present?
        generate_table.html_safe
      else
        generate_no_data
      end
    end

    def render_file_content format = :csv, options = {}
      case format
      when :csv
        render_csv_content options
      end
    end

    def render_csv_content options = {}
      CSV.generate do |csv|
        csv << render_file_header(options)

        @data.each do |object|
          csv << render_file_row(object, options)
        end
      end
    end

    def render_file_header options = {}
      file_render_columns.select{|column| column != :actions}.map do |column_name|
        if @columns[column_name][:options][:title].nil?
          column_name.to_s.titleize
        else
          if @columns[column_name][:options][:title].is_a?(Proc)
            @columns[column_name][:options][:title].call
          elsif @columns[column_name][:options][:title] == false
            ""
          else
            @columns[column_name][:options][:title]
          end
        end
      end
    end

    def render_file_row object, options = {}
      file_render_columns.select{|column| column != :actions}.map do |attribute_name|
        generate_file_column(object, attribute_name, options)
      end
    end

    def file_render_columns
      render_columns = @column_order.reject { |attribute_name|
        @columns[attribute_name][:options][:skip_file_generation].present? && @columns[attribute_name][:options][:skip_file_generation]
      }
    end

    def generate_file_column object, attribute_name, options = {}
      block = @columns[attribute_name][:block]

      if block.present?
        file_value = @columns[attribute_name][:options][:file_value]
        if file_value.present?
          value = if file_value.is_a?(Proc)
            file_value.call(object)
          elsif file_value.is_a? Symbol
            object.send(file_value)
          else
            file_value
          end
          value.to_s.gsub /\n|\r/, " "
        else
          raise ArgumentError, "For the block generated columns you need to provide alternative file_value in the options to be able to generate file."
        end

      elsif object_has_attribute? object, attribute_name
        value = object.send(attribute_name)

        if value.is_a?(TrueClass)
          "Yes"
        elsif value.is_a?(FalseClass)
          "No"
        else
          value.to_s.gsub /\n|\r/, " "
        end
      elsif attribute_name == :actions
        ''
      else
        raise ArgumentError, "Provided attribute name does not exist on the model, if you want to have custom field inside the file content please define file_value options for a column"
      end

    end

    def generate_table
      table_wrapping do
        html_options = @options[:html].presence || {}
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
      table_wrapping do
        label = @options[:no_data] || "There are no data."
        haml_tag :div, label, class: 'no-data alert alert-warning'
      end
    end

    def table_wrapping(&block)
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
            title = if @columns[column_name][:options][:title].nil?
              column_name.to_s.titleize
            else
              if @columns[column_name][:options][:title].is_a?(Proc)
                @columns[column_name][:options][:title].call
              elsif @columns[column_name][:options][:title] == false
                ""
              else
                @columns[column_name][:options][:title]
              end
            end

            classes = ""
            data = {}

            if @columns[column_name][:options][:sortable].present?
              classes << " sortable"

              data[:sort] = if [String, Symbol].include?(@columns[column_name][:options][:sortable].class)
                @columns[column_name][:options][:sortable].to_s
              else
                column_name
              end

              if @sortable[:sort] == column_name.to_s ||
                 @sortable[:sort] == @columns[column_name][:options][:sortable].to_s

                classes << " active-column"
                data[:direction] = @sortable[:direction] == 'asc' ? 'desc' : 'asc' # Inversion on click
              else
                data[:direction] = 'asc'
              end
            end

            html_options = {
              class: classes,
              data: data
            }

            if @columns[column_name][:options][:html].present?
              html_options.merge! @columns[column_name][:options][:html]
            end

            forbidden = [:select, :checkbox, :actions].include? column_name
            if !forbidden
              if html_options[:class].present?
                html_options[:class] << " #{column_name} "
              else
                html_options[:class] = " #{column_name} "
              end
            end

            haml_tag :td, html_options do
              if @columns[column_name][:options][:sortable].present?
                if @sortable[:sort] == column_name.to_s ||
                  @sortable[:sort] == @columns[column_name][:options][:sortable].to_s

                  haml_tag :i, '', class: "fa fa-sort-#{sortable[:direction]}"
                else
                  haml_tag :i, '', class: "fa fa-sort"
                end
              end

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
      if @data.current_page == 1
        "1 to #{@data.limit_value > @data.total_count ? @data.total_count : @data.limit_value} out of #{@data.total_count} records displayed"
      elsif @data.current_page == @data.num_pages
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
      children = parent.public_send(@options[:children_rows])

      if children.present?
        render_row parent, class: @options[:children_row_html][:parent_class]

        parent.public_send(@options[:children_rows]).each do |child|
          render_row child, class: @options[:children_row_html][:child_class]
        end
      else
        render_row parent, class: @options[:children_row_html][:free_class]
      end
    end

    def render_row object, row_options = {}
      classes = " "
      if @options[:table_row].present?
        classes << "#{@options[:table_row][:class]} "
      end

      if row_options[:class].present?
        classes << " #{row_options[:class]}"
      end

      html_id = "#{object.class.model_name.to_s.underscore}_row_#{object.id}"

      haml_tag :tr, class: classes, id: html_id do
        @column_order.each do |attribute_name|
          generate_column(object, attribute_name)
        end
      end
    end

    def generate_column object, attribute_name
      block = @columns[attribute_name][:block]

      if block.present?
        options = @columns[attribute_name][:options][:html].present? ? @columns[attribute_name][:options][:html] : {}

        forbidden = [:select, :checkbox, :actions].include? attribute_name
        if !forbidden
          if options[:class].present?
            options[:class] << " #{attribute_name} "
          else
            options[:class] = " #{attribute_name} "
          end
        end

        haml_tag :td, instance_exec(object, &block), options
      elsif object_has_attribute?(object, attribute_name)

        process_builder(object, attribute_name)

      elsif attribute_name == :actions
        Table::ActionBuilder.generate_field(object, attribute_name, @columns[attribute_name][:options].merge(haml_buffer: haml_buffer))

      else
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

      haml_buffer = self.send(:haml_buffer)
      klass.generate_field(object, attribute_name, @columns[attribute_name][:options].merge(haml_buffer: haml_buffer, controller: controller))
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
      else
        nil
      end
    end

    def method_missing name, *args, &block
      controller.view_context.send(name, *args)
    end

    def to_s
      render
    end
  end
end
