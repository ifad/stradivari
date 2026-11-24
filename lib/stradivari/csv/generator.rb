require 'cgi/escape'
require 'csv'

module Stradivari
  module CSV
    class Generator < Stradivari::Table::Generator
      class Column < Table::Generator::Column
        def to_s(object)
          if @renderer.present?
            render_text(object)
          else
            build(object)
          end.to_s.strip
        end

        protected

        # capture and ERB output HTML-escape the block's text; file cells hold it raw.
        def render_text(object)
          CGI.unescapeHTML(capture { view.instance_exec(object, &@renderer) }.to_s)
        end
      end

      def to_s
        render_csv_content.html_safe # rubocop:disable Rails/OutputSafety -- CSV text, not HTML: <%= %> must emit it unescaped
      end

      protected

      def render_csv_content
        ::CSV.generate do |csv|
          csv << render_file_header

          @data.each do |object|
            csv << render_file_row(object)

            next unless (children = self.children(object))

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
