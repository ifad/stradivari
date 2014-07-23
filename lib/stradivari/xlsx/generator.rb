require 'axlsx'

module Stradivari
  module XLSX
    class Generator < CSV::Generator

      class Column < CSV::Generator::Column
        def to_s(object)
          if @renderer.present?
            capture_haml { view.instance_exec(object, &@renderer) }
          elsif opts.fetch(:type, nil)
            object.public_send(@name)
          else
            build(object)
          end
        end
      end

      def to_s
        xlsx.to_stream.read.html_safe.force_encoding('BINARY')
      end

      protected
        def xlsx
          Axlsx::Package.new do |package|
            package.use_shared_strings = true
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

          sheet.add_row @columns.map(&:title),
            types: [:string] * @columns.size,
            style: heading
        end

        def render_body(sheet)
          @data.each do |object|
            sheet.add_row(@columns.map {|col| col.to_s(object) }, types: types)
          end
        end

      private
        def types
          @_types ||= @columns.map {|c| c.opts.fetch(:type, nil)}
        end
    end
  end
end

