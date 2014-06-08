require 'filter/helpers'

module Filter
  class Builder::BooleanField < Builder

    def self.render
      lambda do |attr, opts|
        title = opts.fetch(:title, attr.to_s.humanize)
        attr  = opts[:is_scoped] ? attr : [attr, 'eq'].join('_')

        haml_tag :div, class: "form-group" do
          if opts.fetch(:tristate, false)
            haml_concat label(opts[:namespace], attr, title)
            instance_exec(&Helpers.radios_for_collection([['Yes', 'true'], ['No', 'false']], attr, opts))

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
