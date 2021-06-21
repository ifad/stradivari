# frozen_string_literal: false

module Stradivari
  module XLSX
    module Controller
      def render_xlsx(options = {})
        filename = _stradivari_xlsx_file_name(options.delete(:filename))

        xlsx = render_to_string(options.merge(formats: [:xlsx]))

        # FIXME: This hack to bypass HAML does not allow to use
        # frozen_string_literal directive in this file because concat will
        # fail (only when called by the controller)
        if xlsx[-1] == "\n"
          xlsx.slice!(-1)
          xlsx.concat "\x00".force_encoding('BINARY') * 4
        end

        send_data xlsx, type: :xlsx,
                        disposition: options.fetch(:disposition, 'attachment'),
                        status: options.fetch(:status, 200),
                        filename: filename
      end

      def _stradivari_xlsx_file_name(filename)
        filename =
          if filename.nil? || filename.strip.length.zero?
            +'export'
          else
            filename.dup
          end

        filename.sub!(/\.xlsx$/i, '')

        if filename.length > 119
          filename = +"#{filename[0..118]}-cut" # 119 + 4 = 123
        end

        # Here we reach at most 128 chars.
        filename << '.xlsx'

        filename
      end
    end
  end
end
