module Stradivari
  module Filter
    class Builder::CheckboxField < Builder

      def self.render
        lambda do |attr, opts|
          def cb(name, label, value, checked, opts)
            haml_tag :div, class: 'checkbox' do
              haml_tag :label do
                haml_concat check_box(opts[:namespace], name, {multiple: true, value: value, checked: checked}, value, nil)
                haml_concat label
              end
            end
          end

          type     = opts.fetch :type , :single_line
          title    = opts.fetch :title, attr.to_s.humanize
          values   = opts.fetch :value, nil
          name     = opts[:is_scoped] ? attr : [attr, 'in'].join('_')

          values   ||= []
          collection = opts[:collection]
          collection = collection.call if collection.respond_to?(:call)

          unless collection.each.first.is_a?(Array)
            collection.map! {|item| [ item, item ] }
          end

          # Display checked items first
          checked, unchecked = collection.partition {|_, value| values.include?(value.to_s)}
          opts[:collapsed_field] = true if type == :multi_line && checked.present?

          haml_tag :div, class: 'form-group' do
            instance_exec(&Helpers::render_title(name, title, opts))

            classes = Builder::prepare_classes(opts, (type == :single_line ? 'form-inline' : 'multi-line'))
            haml_concat hidden_field(opts[:namespace], name, value: '')
            haml_tag :div, class: classes do
              if type == :multi_line

                checked.each {|label, value| cb(name, label, value, true, opts) }
                if checked.present?
                  haml_tag :div, class: 'closed' do
                    haml_tag :hr
                    unchecked.each {|label, value| cb(name, label, value, false, opts)}
                  end
                else
                  unchecked.each {|label, value| cb(name, label, value, false, opts)}
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
