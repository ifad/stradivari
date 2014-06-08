module Filter
  class Builder::SearchField < Builder

    def self.render
      lambda do |attr, opts|
        attr  = opts[:is_scoped] ? attr : [attr, 'cont'].join('_')

        haml_tag :div, class: 'form-group' do
          value = opts[:value]
          if opts[:skip_button]
            haml_concat label(opts[:namespace], attr, opts[:title] || "Search #{attr.to_s.humanize}")
            haml_concat text_field(opts[:namespace], attr, value: value, class: 'form-control', placeholder: opts[:title] || "Search #{attr.to_s.humanize}")
          else
            haml_tag :div, class: 'input-group' do
              haml_concat text_field(opts[:namespace], attr, value: value, class: 'form-control', placeholder: opts[:title] || "Search #{attr.to_s.humanize}")
              haml_tag :span, class: 'input-group-btn' do
                haml_tag :button, type: 'button', class: 'btn btn-primary search' do
                  haml_tag :i, class: 'fa fa-search'
                  haml_concat 'Search'
                end
              end
            end
          end
        end
      end
    end

    def self.value(params, name)
      params[name] || params["#{name}_cont"]
    end

  end
end
