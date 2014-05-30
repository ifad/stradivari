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

    NAMESPACE = Filter::NAMESPACE

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

      instance_exec &block if block.present?

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

    def full_text_search_field field_attribute, options = {}
      field :full_text_search_field, field_attribute, options
    end

    def prepend &block
      @prepended_content = block
    end

    def append &block
      @appended_content = block
    end

    def render options = {}
      if class_name.present?
        @detached_fields = options.fetch(:detached_fields, [])
        @detached_form   = options.fetch(:detached_form,   false)
        @inline_form     = options.fetch(:inline_form,     false)

        if @detached_form
          save_field_order = @field_order
          @field_order = @detached_fields
        end

        content = generate_form.html_safe

        if @detached_form
          @field_order = save_field_order - @detached_fields
        end

        content
      else
        "Wrong class for generating filter table"
      end
    end

    def generate_form
      id = @options[:id].present? ? @options[:id] : "filter_fields_for_#{ActiveModel::Naming.singular(@klass)}"
      form_classes = 'filter-form '
      form_classes << 'form-inline '   if @inline_form
      form_classes << 'detached-form ' if @detached_form

      capture_haml do
        haml_tag :div, class: @options[:class] do

          id, link = id, [ id, 'detached' ].join('_')
          id, link = link, id if @detached_form

          haml_tag :form, class: form_classes, role: 'form', id: id, data: { link: link } do
            haml_tag :input, type: :hidden, name: :sort,      value: request.params[:sort]
            haml_tag :input, type: :hidden, name: :direction, value: request.params[:direction]

            haml_tag :div, class: (@detached_form ? '' : 'panel panel-info') do
              generate_actions if !@detached_form && @field_order.count > 5

              if !@detached_form && @prepended_content.present?
                haml_tag :div, view_eval(&@prepended_content), class: 'panel-body prepended'
              end

              generate_active_fields
              generate_inactive_fields

              if !@detached_form && @appended_content.present?
                haml_tag :div, view_eval(&@appended_content), class: 'panel-body appended'
              end

              generate_actions if !@detached_form
            end
          end
        end
      end
    end

    def detached_form options = {}
      options.reverse_merge!(detached_form: true)
      render options
    end

    def generate_active_fields
      @active_fields = []
      @field_order.each do |field_attribute|
        @active_fields << field_attribute if active_field?(field_attribute)
      end

      haml_tag :div, class: (@detached_form ? '' : 'panel-heading') do
        @active_fields.each { |field_attribute| generate_field(field_attribute) }
      end if @active_fields.count > 0

      @field_order = @field_order - @active_fields
    end

    def generate_inactive_fields
      haml_tag :div, class: (@detached_form ? '' : 'panel-body') do
        @field_order.each { |field_attribute| generate_field(field_attribute) }
      end if @field_order.count > 0
    end

    def generate_actions
      invoke_builder(Filter::ActionFieldBuilder, :action_field)
    end

    def active_field? field_attribute
      field_name = @fields[field_attribute][:options][:field_name] || field_attribute

      case @fields[field_attribute][:field_type]
      when :number_field
        @options[NAMESPACE][field_name].present? ||
        @options[NAMESPACE]["#{field_attribute}_eq"].present? ||
        @options[NAMESPACE]["#{field_attribute}_lt"].present? ||
        @options[NAMESPACE]["#{field_attribute}_gt"].present?
      when :selection_field
        @options[NAMESPACE][field_name].present? ||
        @options[NAMESPACE]["#{field_attribute}_eq"].present? ||
        @options[NAMESPACE]["#{field_attribute}"].present?
      when :date_range_field
        @options[NAMESPACE][field_name].present? ||
        @options[NAMESPACE]["#{field_attribute}_gteq"].present? ||
        @options[NAMESPACE]["#{field_attribute}_lteq"].present?
      when :boolean_field
        @options[NAMESPACE][field_name].present? ||
        @options[NAMESPACE]["#{field_attribute}_eq"].present?
      when :checkbox_field
        @options[NAMESPACE][field_name].present? ||
        @options[NAMESPACE]["#{field_attribute}_in"].present? ||
        @options[NAMESPACE][@fields[field_attribute][:options][:scope]].present?
      when :full_text_search_field
        @options[NAMESPACE][field_name].present? ||
        @options[NAMESPACE][field_attribute].present?
      else
        @options[NAMESPACE]["#{field_attribute}_cont"].present?
      end
    end

    def generate_field field_attribute
      if class_object.columns_hash[field_attribute.to_s].present? ||
        class_object._ransackers[field_attribute.to_s].present? ||
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
      value   = @options[NAMESPACE][field_attribute]

      klass = if builder.present?
        builder
      else
        field_name = @fields[field_attribute][:options][:field_name]

        case @fields[field_attribute][:field_type]
        when :selection_field
          value = @options[NAMESPACE][field_name] ||
                  @options[NAMESPACE]["#{field_attribute}_eq"] ||
                  @options[NAMESPACE]["#{field_attribute}"]
          Filter::SelectionFieldBuilder

        when :date_range_field
          field_name = @fields[field_attribute][:options][:field_name]
          field_value = field_name.present? ? field_name : field_attribute
          value = [@options[NAMESPACE]["#{field_value}_gteq"],
                   @options[NAMESPACE]["#{field_value}_lteq"]]
          Filter::DateRangeFieldBuilder

        when :number_field
          value = if @options[NAMESPACE]["#{field_attribute}_lt"].present?
            ["#{field_attribute}_lt", @options[NAMESPACE]["#{field_attribute}_lt"]]
          elsif @options[NAMESPACE]["#{field_attribute}_gt"].present?
            ["#{field_attribute}_gt", @options[NAMESPACE]["#{field_attribute}_gt"]]
          else
            ["#{field_attribute}_eq", @options[NAMESPACE]["#{field_attribute}_eq"]]
          end

          Filter::NumberFieldBuilder
        when :boolean_field
          value = @options[NAMESPACE][field_attribute] ||
                  @options[NAMESPACE]["#{field_attribute}_is_true"]  ||
                  @options[NAMESPACE]["#{field_attribute}_is_false"] ||
                  @options[NAMESPACE]["#{field_attribute}_eq"]
          Filter::BooleanFieldBuilder

        when :checkbox_field
          value = @options[NAMESPACE]["#{field_attribute}_in"] ||
                  @options[NAMESPACE][@fields[field_attribute][:options][:scope]]
          Filter::CheckboxFieldBuilder

        when :full_text_search_field
          value   = @options[NAMESPACE][field_attribute]
          Filter::FullTextSearchFieldBuilder

        else
          value   = @options[NAMESPACE]["#{field_attribute}_cont"]
          Filter::SearchFieldBuilder
        end
      end

      invoke_builder(klass, field_attribute, value, options)
    end

    def invoke_builder(klass, field_attribute, value = nil, options = {})
      klass.generate_field(class_object, field_attribute, options.merge(
        haml_buffer: self.send(:haml_buffer), value: value, detached_form: @detached_form, inline_form: @inline_form
      ))
    end

    def method_missing name, *args, &block
      view_context.send(name, *args)
    end

    def view_eval(&block)
      view_context.instance_eval(&block)
    end

    def view_context
      controller.view_context
    end

    def to_s
      render
    end

  end
end
