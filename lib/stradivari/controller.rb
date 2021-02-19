# frozen_string_literal: true

require 'active_support/concern'

module Stradivari
  module Controller
    extend ActiveSupport::Concern

    included do
      helper_method :sort_column
      helper_method :sort_direction
      helper_method :sortable
    end

    module ClassMethods
      def stradivari_filter(model, options = {})
        module_eval do
          define_method(:sorting_object_class) { model }

          if (col = options.fetch(:default_sorting, nil))
            define_method(:default_sort_column) { col }
          end

          if (dir = options.fetch(:default_direction, nil))
            define_method(:default_sort_direction) { dir }
          end
        end
      end
    end

    protected

    def sorting_object_class
      controller_name.singularize.camelize.constantize
    rescue NameError
      raise Error,
            "Can't infer the associated model name for controller `#{controller_name}`. You need to define a `sorting_object_class` method on it to use sorting"
    end

    def default_sort_column
      'id'
    end

    def default_sort_direction
      'ASC'
    end

    def sort_column
      if params[:sort].present? && sorting_object_class.sortable_by?(params[:sort])
        params[:sort]
      elsif params[:sort] == 'nil'
        nil
      else
        default_sort_column
      end
    end

    def sort_direction
      /^(asc|desc)$/i.match?(params[:direction]) ? params[:direction] : default_sort_direction
    end

    def sortable
      { sort: sort_column, direction: sort_direction.downcase }
    end

    def stradivari_filter_options
      options = params[Filter::NAMESPACE] || {}
      # params validation is done in Filter::Model.
      options.permit! if options.respond_to?(:permit!)

      sortable.merge(options)
    end
    alias ransack_options stradivari_filter_options

    def stradivari_filter(model)
      model.stradivari_filter(stradivari_filter_options)
    end
  end
end
