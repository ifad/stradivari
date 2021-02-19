# frozen_string_literal: true

module Stradivari
  module Filter
    class Builder::CheckboxField < Builder
      def self.render
        lambda do |attr, opts|
          def cb(name, title, value, checked, opts)
            haml_tag :label, class: 'custom-control custom-checkbox custom-control-inline' do
              haml_concat check_box(opts[:namespace], name,
                                    { multiple: true, value: value, checked: checked, class: 'custom-control-input' }, value, nil)
              haml_tag :span, title, class: 'custom-control-label custom-control-label--stradivari'
            end
          end

          type     = opts.fetch :type, :single_line
          title    = opts.fetch :title, attr.to_s.humanize
          values   = opts.fetch :value, nil
          name     = opts[:is_scoped] ? attr : [attr, 'in'].join('_')

          values   ||= []
          collection = opts[:collection]
          collection = collection.call if collection.respond_to?(:call)

          collection.map! { |item| [item, item] } unless collection.each.first.is_a?(Array)

          # Display checked items first
          checked, unchecked = collection.partition { |_, value| values.include?(value.to_s) }
          opts[:collapsed_field] = true if type == :multi_line && checked.present?

          haml_tag :div, class: 'form-group form-group--stradivari' do
            instance_exec(&Helpers.render_title(name, title, opts))

            classes = Builder.prepare_classes(opts, (type == :single_line ? 'stradivari-options--one-line' : 'stradivari-options--multi-line'))
            haml_concat hidden_field(opts[:namespace], "#{name}[]", value: '')
            haml_tag :div, class: classes do
              if type == :multi_line

                checked.each { |label, value| cb(name, label, value, true, opts) }
                if checked.present?
                  haml_tag :div, class: 'collapse collapse--stradivari' do
                    unchecked.each { |label, value| cb(name, label, value, false, opts) }
                  end
                else
                  unchecked.each { |label, value| cb(name, label, value, false, opts) }
                end
              else
                collection.each do |label, value|
                  cb(name, label, value, values.include?(value.to_s), opts)
                end
              end
            end
          end
        end
      end

      def self.value(params, name)
        params[name] || params["#{name}_in"]
      end
    end
  end
end
