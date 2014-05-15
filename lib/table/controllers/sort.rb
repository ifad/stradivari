require 'active_support/concern'

module Table
  module Controllers
    module Sort
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
          "asc"
        end

        def sort_column
          if params[:sort].present? &&
            (sorting_object_class._ransackers[params[:sort]].present? ||
            sorting_object_class.column_names.include?(params[:sort]) ||
            sorting_object_class.respond_to?(['sort_by', params[:sort], 'asc'].join('_')) ||
            sorting_object_class.reflections.keys.any? {|related| params[:sort].include? related.to_s })

            params[:sort]
          else
            default_sort_column
          end
        end

        def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : default_sort_direction
        end

        def sortable
          { sort: sort_column, direction: sort_direction }
        end

        def ransack_options
          sortable.merge(params[:search_fields].presence || {})
        end

    end
  end
end
