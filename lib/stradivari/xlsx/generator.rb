require 'axlsx'

module Stradivari
  module XLSX
    class Generator < CSV::Generator

      class Column < CSV::Generator::Column
        # Like parent
      end

      def to_s
        xlsx.to_stream.read.html_safe.force_encoding('BINARY')
      end

      protected

        def xlsx
          Axlsx::Package.new do |package|
            package.workbook.add_worksheet do |sheet|
              render_header(sheet)
              render_body(sheet)
            end
          end
        end

        def render_header(sheet)
          heading = sheet.styles.add_style sz: 15,
            bg_color: 'dddddd', fg_color: '000000',
            border: Axlsx::STYLE_THIN_BORDER

          sheet.add_row @columns.map(&:title), styles: heading
        end

        def render_body(sheet)
          @data.each do |object|
            sheet.add_row(@columns.map {|col| col.to_s(object) })
          end
        end

    end
  end
end

