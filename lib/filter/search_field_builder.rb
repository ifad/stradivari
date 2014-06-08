module Filter
  class SearchFieldBuilder
    def self.render
      lambda do |_, attr, opts|
        haml_tag :div, class: 'form-group' do
          value = opts[:value]
          haml_concat label(opts[:namespace], "#{attr}_cont", opts[:title] || "Search #{attr.to_s.humanize}")
          haml_concat text_field(opts[:namespace], "#{attr}_cont", value: value, class: 'form-control')
        end
      end
    end
  end
end
