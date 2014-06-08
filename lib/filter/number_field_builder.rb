module Filter
  class NumberFieldBuilder

    def self.render
      lambda do |attr, opts|
        value = opts[:value].last

        select_opts = [
          ['Greater Than', "#{attr}_gt"],
          ['Equal To', "#{attr}_eq"],
          ['Less Than', "#{attr}_lt"]
        ]

        haml_tag :div, class: "form-group" do
          haml_concat label(opts[:namespace], "#{attr}_eq", opts[:title] || attr.to_s.humanize)
          haml_tag :div, class: "input-number" do
            haml_concat select(nil, nil, options_for_select(select_opts, selected: opts[:value].first), {}, class: 'form-control')
            haml_concat text_field(opts[:namespace], opts[:value].first, value: value, class: 'form-control')
          end
        end
      end
    end

    def self.value(params, name)
      if params["#{name}_lt"].present?
        [ "#{name}_lt", params["#{name}_lt"] ]

      elsif params["#{name}_gt"].present?
        [ "#{name}_gt", params["#{name}_gt"] ]

      else
        [ "#{name}_eq", params["#{name}_eq"] ]

      end
    end

    def self.active?(params, name)
       !! [ params["#{name}_eq"], params["#{name}_lt"], params["#{name}_gt"] ].find(&:present?)
    end

  end
end
