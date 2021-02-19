# frozen_string_literal: true

module Stradivari
  module CSV
    class Generator < Stradivari::Table::Generator
      class Column < Table::Generator::Column
        def to_s(object)
          if @renderer.present?
            capture_haml { view.instance_exec(object, &@renderer) }
          else
            build(object)
          end.to_s.strip
        end
      end

      def to_s
        renderer = -> { render_csv_content }

        capture_haml(&renderer)
      end

      protected

      def render_csv_content
        ::CSV.generate do |csv|
          csv << render_file_header

          @data.each do |object|
            csv << render_file_row(object)

            next unless children = self.children(object)

            children.each do |child|
              csv << render_file_row(child)
            end
          end
        end
      end

      def render_file_header
        @columns.map(&:title)
      end

      def render_file_row(object)
        @columns.map { |col| col.to_s(object) }
      end
    end
  end
end
