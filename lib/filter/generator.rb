module Filter
  class Generator
    include Haml::Helpers
    include ActionView::Context
    include Kaminari::ActionViewExtension
    include Kaminari::Helpers
    include ActionView::Helpers::UrlHelper
    include ActionController::UrlFor
    # include ActionView::Helpers::TagHelper
    include Rails.application.routes.url_helpers

    DEFAULT_FILTER_OPTIONS = {
      class: 'filter-form-container ',
      id:    'filter-form'
    }

    DEFAULT_FIELD_OPTIONS = {

    }

    def initialize
      self.init_haml_helpers

      @fields = {}
      @field_order = []
    end

    def controller
      @options[:controller] || ApplicationController
    end

    def request
      controller.request
    end

    def env
      controller.env
    end

    def class_object
      @klass
    end

    def class_name
      class_object.to_s.downcase
    end

    def class_symbol
      class_name.to_sym
    end

    def self.generate_filter_for klass, options = {}, &block
      new.filter_for(klass, options, &block)
    end

    def filter_for klass, options = {}, &block
      @klass = klass
      @options = options.reverse_merge Filter::Generator::DEFAULT_FILTER_OPTIONS

      instance_eval &block if block.present?

      self
    end

    def field field_type, field_attribute, options = {}
      field_attribute = field_attribute.to_sym unless field_attribute.is_a? Symbol
      field_type = field_type.to_sym unless field_type.is_a? Symbol

      unless @fields.has_key? field_attribute
        @fields[field_attribute] = {
          options: options.reverse_merge(Filter::Generator::DEFAULT_FIELD_OPTIONS),
          field_type: field_type
        }
        @field_order << field_attribute
      end
    end

    %w[search selection date_range boolean checkbox number].each do |field_type|
      define_method "#{field_type}_field" do |field_attribute, options = {}|
        field "#{field_type}_field", field_attribute, options
      end
    end

    def action_fields options = {}
      field :action_field, :action_field, options
    end

    def full_text_search_field field_attribute, options = {}
      field :full_text_search_field, field_attribute, options
    end

    def custom_form_content &block
      @custom_form_content = block
    end

    def render options = {}
      if class_name.present?
        @detached_fields = options[:detached_fields] || []
        @detached_form   = options[:detached_form]   || false
        @inline_form     = options[:inline_form]     || false

        if @detached_form
          @temp_field_order = @field_order
          @field_order = @detached_fields
        end

        content = generate_form.html_safe

        if @detached_form
          @field_order = @temp_field_order - @detached_fields
          remove_instance_variable(:@temp_field_order)
        end

        content
      else
        "Wrong class for generating filter table"
      end
    end

    def generate_form
      id = @options[:id].present? ? @options[:id] : "filter_fields_for_#{ActiveModel::Naming.singular(@klass)}"
      data = {form: id}
      form_classes = 'filter-form '
      form_classes << 'form-inline detached-form ' + id if @inline_form


      capture_haml do
        haml_tag :div, class: @options[:class] do
          haml_tag '.filter-header', "Filters" unless @detached_form
          haml_tag :form, class: form_classes, role: 'form', id: @detached_form ? '' : id, data: data  do
            if @custom_form_content.present?
              haml_tag 'custom_content', @custom_form_content.call
            end
            
            generate_field(:action_field) if @field_order.include? :action_field
            generate_active_fields
            generate_inactive_fields

          end
        end
      end
    end

    def generate_active_fields
      @active_fields = []
      @field_order.each do |field_attribute|
        @active_fields << field_attribute if active_field(field_attribute)
      end

      haml_tag :div, class: 'active-fields' do
        @active_fields.each { |field_attribute| generate_field(field_attribute) }
        generate_field(:action_field) if @detached_form && @inline_form

      end if @active_fields.count > 0

      @field_order = @field_order - @active_fields
    end

    def generate_inactive_fields
      haml_tag :div, class: 'inactive-fields' do
        @field_order.each do |field_attribute|
          generate_field(field_attribute)
        end

        if @detached_form && 
           @inline_form

          generate_field(:action_field)
        end
      end if @field_order.count > 0
    end

    def active_field field_attribute
      field_name = @fields[field_attribute][:options][:field_name] || field_attribute

      case @fields[field_attribute][:field_type]
      when :action_field
        false
      when :number_field
        @options[:search_fields][field_name].present? ||
        @options[:search_fields]["#{field_attribute}_eq"].present? ||
        @options[:search_fields]["#{field_attribute}_lt"].present? ||
        @options[:search_fields]["#{field_attribute}_gt"].present?
      when :selection_field
        @options[:search_fields][field_name].present? ||
        @options[:search_fields]["#{field_attribute}_equals"].present? ||
        @options[:search_fields]["#{field_attribute}_eq"].present? ||
        @options[:search_fields]["#{field_attribute}"].present?
      when :date_range_field
        @options[:search_fields][field_name].present? ||
        @options[:search_fields]["#{field_attribute}_gteq"].present? ||
        @options[:search_fields]["#{field_attribute}_lteq"].present?
      when :boolean_field
        @options[:search_fields][field_name].present? ||
        @options[:search_fields]["#{field_attribute}_equals"].present? ||
        @options[:search_fields]["#{field_attribute}_eq"].present?
      when :checkbox_field
        @options[:search_fields][field_name].present? ||
        @options[:search_fields]["#{field_attribute}_in"].present? ||
        @options[:search_fields][@fields[field_attribute][:options][:scope]].present?
      when :full_text_search_field
        @options[:search_fields][field_name].present? ||
        @options[:search_fields][field_attribute].present?
      else
        @options[:search_fields]["#{field_attribute}_cont"].present?
      end
    end

    def generate_field field_attribute
      if class_object.columns_hash[field_attribute.to_s].present? ||
        class_object._ransackers[field_attribute.to_s].present? ||
        field_attribute == :action_field ||
        field_attribute.to_s =~ /or|and/ ||
        @fields[field_attribute][:options][:field_name].present?

        if class_object._ransackers[field_attribute.to_s].present?
          @fields[field_attribute][:options][:attribute_type] = :ransack
        else
          @fields[field_attribute][:options][:attribute_type] = :active_record
        end

        process_builder field_attribute
      else
        raise ArgumentError, "Provided attribute '#{field_attribute.to_s}' does not exist on #{class_object.to_s} class."
      end
    end

    def process_builder field_attribute
      options = @fields[field_attribute][:options]
      builder = options[:builder]
      value   = @options[:search_fields][field_attribute]

      klass = if builder.present?
        builder
      else
        field_name = @fields[field_attribute][:options][:field_name]

        case @fields[field_attribute][:field_type]
        when :action_field
          Filter::ActionFieldBuilder
        when :selection_field
          value = @options[:search_fields][field_name] ||
                  @options[:search_fields]["#{field_attribute}_equals"] ||
                  @options[:search_fields]["#{field_attribute}_eq"] ||
                  @options[:search_fields]["#{field_attribute}"]
          Filter::SelectionFieldBuilder

        when :date_range_field
          field_name = @fields[field_attribute][:options][:field_name]
          field_value = field_name.present? ? field_name : field_attribute
          value = [@options[:search_fields]["#{field_value}_gteq"],
                   @options[:search_fields]["#{field_value}_lteq"]]
          Filter::DateRangeFieldBuilder

        when :number_field
          value = if @options[:search_fields]["#{field_attribute}_lt"].present?
            ["#{field_attribute}_lt", @options[:search_fields]["#{field_attribute}_lt"]]
          elsif @options[:search_fields]["#{field_attribute}_gt"].present?
            ["#{field_attribute}_gt", @options[:search_fields]["#{field_attribute}_gt"]]
          else
            ["#{field_attribute}_eq", @options[:search_fields]["#{field_attribute}_eq"]]
          end

          Filter::NumberFieldBuilder
        when :boolean_field
          value = @options[:search_fields][field_attribute] ||
                  @options[:search_fields]["#{field_attribute}_is_true"]  ||
                  @options[:search_fields]["#{field_attribute}_is_false"] ||
                  @options[:search_fields]["#{field_attribute}_eq"]   ||
                  @options[:search_fields]["#{field_attribute}_equals"]
          Filter::BooleanFieldBuilder

        when :checkbox_field
          value = @options[:search_fields]["#{field_attribute}_in"] ||
                  @options[:search_fields][@fields[field_attribute][:options][:scope]]
          Filter::CheckboxFieldBuilder

        when :full_text_search_field
          value   = @options[:search_fields][field_attribute]
          Filter::FullTextSearchFieldBuilder

        else
          value   = @options[:search_fields]["#{field_attribute}_cont"]
          Filter::SearchFieldBuilder
        end
      end

      haml_buffer = self.send(:haml_buffer)

      options = options.merge(haml_buffer: haml_buffer, value: value, detached_form: @detached_form, inline_form: @inline_form)
      klass.generate_field(class_object, field_attribute, options)
    end

    def method_missing name, *args, &block
      controller.view_context.send(name, *args)
    end

    def detached_form options = {}
      options.reverse_merge!({detached_form: true, inline_form: true})
      render options
    end

    def to_s
      render
    end
  end
end
