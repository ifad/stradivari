module Filter
  class BooleanFieldBuilder

    def self.render
      lambda do |_, attr, opts|
        title = opts.fetch(:title, attr.to_s.humanize)
        attr  = opts[:is_scoped] ? attr : [attr, 'eq'].join('_')

        haml_tag :div, class: "form-group" do
          if opts.fetch(:tristate, false)

            # TODO make this a radio
            haml_concat label(opts[:namespace], attr, title)
            haml_concat select(opts[:namespace], name, [['Yes', 'true'], ['No', 'false']], {include_blank: 'Any', selected: value}, {class: 'form-control'})

          else
            haml_tag :div, class: 'checkbox' do
              haml_tag :label do
                haml_concat check_box(opts[:namespace], attr, {checked: opts[:value].present?}, 'true', nil)
                haml_concat title
              end
            end
          end
        end
      end
    end
  end
end
