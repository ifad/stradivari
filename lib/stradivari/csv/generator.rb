module Stradivari
  module CSV
    class Generator < Stradivari::Table::Generator

      TABLE_OPTIONS = {
        format: :html,
      }

      class Column
        def to_s object
          if @renderer.present?
            capture_haml { view.instance_exec(object, &@renderer) }
          else
            build(object)
          end
        end
      end

      def to_s
        renderer = lambda { render_csv_content }

        capture_haml(&renderer)
      end

      protected

        def render_csv_content
          ::CSV.generate do |csv|
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

    end
  end
end
