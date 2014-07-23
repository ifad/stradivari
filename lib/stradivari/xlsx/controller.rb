module Stradivari
  module XLSX

    module Controller
      def render_xlsx(options = {})
        xlsx = render_to_string

        if xlsx[-1] == "\n" # HACK FIXME bypass HAML
          xlsx.slice! -1
          xlsx.concat "\x00".force_encoding('BINARY')*4
        end

        filename = options.fetch(:filename, nil)
        filename << '.xlsx' unless filename =~ /\.xlsx$/

        send_data xlsx, type: :xlsx,
          disposition: options.fetch(:disposition, 'attachment'),
          status:      options.fetch(:status,      200),
          filename:    filename
      end
    end

  end
end
