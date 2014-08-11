module Stradivari
  module Filter
    class Builder::DateRangeField < Builder

      def self.render
        lambda do |attr, opts|
          from_value = opts[:value].first
          to_value   = opts[:value].last

          haml_tag :div, class: "form-group" do
            instance_exec(&Helpers::render_title(attr, opts.fetch(:title, attr.to_s.humanize), opts))

            haml_tag :div, class: Builder::prepare_classes(opts, "input-daterange") do
              haml_concat text_field(opts[:namespace], "#{attr}_gteq", {value: from_value, class: 'form-control'})
              haml_tag :span, '-', class: "delimiter"
              haml_concat text_field(opts[:namespace], "#{attr}_lteq", {value: to_value,   class: 'form-control'})
            end
          end
        end
      end

      def self.value(params, name)
        [ params["#{name}_gteq"], params["#{name}_lteq"] ]
      end

      def self.active?(params, name)
        !! value(params, name).find(&:present?)
      end

    end
  end
end
