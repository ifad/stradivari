module Filter
  class BooleanFieldBuilder
    def self.render
      lambda do |_, attr, opts|
        value = opts[:value]

        name = "#{attr}_eq"

        haml_tag :div, class: "form-group" do
          if opts[:attribute_type] == :ransack
            haml_concat label(opts[:namespace], attr, opts[:title] || attr.to_s.humanize)
            haml_concat select(opts[:namespace], attr, [['Yes', 'true'], ['No', 'false']], {include_blank: 'Any', selected: value}, {class: 'form-control'})
          elsif opts[:attribute_override_type] == :ransack
            haml_concat label(opts[:namespace], name, opts[:title] || attr.to_s.humanize)
            haml_concat select(opts[:namespace], name, [['Yes', 'true'], ['No', 'false']], {include_blank: 'Any', selected: value}, {class: 'form-control'})
          else
            haml_tag :div, class: 'checkbox' do
              haml_tag :label do
                haml_concat check_box(opts[:namespace], name, {checked: value.present?}, 'true', nil)
                haml_tag :b, opts[:title] || attr.to_s.humanize
              end
            end
          end
        end
      end
    end
  end
end
