require 'stradivari/filter/helpers'

module Stradivari
  module Filter
    class Builder::BooleanField < Builder

      def self.render
        lambda do |attr, opts|
          title = opts.fetch(:title, attr.to_s.humanize)
          attr  = opts[:is_scoped] ? attr : [attr, 'eq'].join('_')

          opts[:collapsed_field] = true if opts[:value].present?

          haml_tag :div, class: "form-group" do
            if opts.fetch(:tristate, false)
              instance_exec(&Helpers::render_title(attr, title, opts))
              haml_tag :div, class: Builder::prepare_classes(opts) do
                instance_exec(&Helpers.radios_for_collection([['Yes', 'true'], ['No', 'false']], attr, opts))
              end
            else
              haml_tag :div, class: 'checkbox single-value' do
                haml_tag :label do
                  haml_concat title
                  haml_concat check_box(opts[:namespace], attr, {checked: opts[:value].present?}, 'true', nil)
                end
              end
            end
          end
        end
      end

    end
  end
end
