module Stradivari
  module XLSX

    module Controller
      def render_xlsx(options = {})
        filename = _stradivari_xlsx_file_name(options.delete(:filename))

        xlsx = render_to_string(options.merge(formats: [:xlsx]))

        if xlsx[-1] == "\n" # HACK FIXME bypass HAML
          xlsx.slice! -1
          xlsx.concat "\x00".force_encoding('BINARY')*4
        end

        send_data xlsx, type: :xlsx,
          disposition: options.fetch(:disposition, 'attachment'),
          status:      options.fetch(:status,      200),
          filename:    filename
      end

      def _stradivari_xlsx_file_name(filename)
        if filename.nil? || filename.strip.length == 0
          filename = 'export'
        end

        if filename.length > 128
          filename = filename[0..118] + '-cut' # 119 + 4 = 123
        end

        # Here we reach at most 128 chars.
        filename << '.xlsx' unless filename =~ /\.xlsx$/

        return filename
      end
    end

  end
end
