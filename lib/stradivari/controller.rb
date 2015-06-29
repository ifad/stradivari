require 'active_support/concern'

module Stradivari
  module Controller
    extend ActiveSupport::Concern

    included do
      helper_method :sort_column
      helper_method :sort_direction
      helper_method :sortable
    end

    protected

      def sorting_object_class
        raise "You need to override this method to use sorting on the controller"
      end

      def default_sort_column
        "id"
      end

      def default_sort_direction
        "ASC"
      end

      def sort_column
        if params[:sort].present? &&
          (sorting_object_class.stradivari_scopes[params[:sort].to_sym].present? ||
          sorting_object_class.column_names.include?(params[:sort]) ||
          sorting_object_class.respond_to?(['sort_by', params[:sort], 'asc'].join('_')) ||
          sorting_object_class.reflections.keys.any? {|related| params[:sort].include? related.to_s })

          params[:sort]
        elsif params[:sort] == 'nil'
          nil
        else
          default_sort_column
        end
      end

      def sort_direction
        params[:direction] =~ /^(asc|desc)$/i ? params[:direction] : default_sort_direction
      end

      def sortable
        { sort: sort_column, direction: sort_direction.downcase }
      end

      def stradivari_filter_options
        sortable.merge(params[Filter::NAMESPACE].presence || {})
      end
      alias ransack_options stradivari_filter_options

      def stradivari_filter(model)
        model.stradivari_filter(stradivari_filter_options)
      end

  end
end
