module Filter
  class DateRangeFieldBuilder
    def self.render
      lambda do |_, attr, opts|
        from_value = opts[:value].first
        to_value   = opts[:value].last

        input_name = opts[:field_name].present? ? opts[:field_name] : attr

        haml_tag :div, class: "form-group" do
          haml_tag :fieldset do
            haml_concat label(opts[:namespace], input_name, opts[:title] || attr.to_s.humanize, for: 'date')
            haml_tag :div, class: "input-daterange" do
              haml_concat text_field(opts[:namespace], "#{input_name}_gteq", {value: from_value, class: 'form-control'})
              haml_tag :span, '-', class: "delimiter"
              haml_concat text_field(opts[:namespace], "#{input_name}_lteq", {value: to_value,   class: 'form-control'})
            end
          end
        end
      end
    end
  end
end
