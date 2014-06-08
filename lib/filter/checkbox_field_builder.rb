module Filter
  class CheckboxFieldBuilder

    def self.render
      lambda do |_, attr, opts|

        def cb(name, label, value, checked, opts)
          haml_tag :div, class: 'checkbox' do
            haml_tag :label do
              haml_concat check_box(opts[:namespace], name, {multiple: true, value: value, checked: checked}, value, nil)
              haml_concat label
            end
          end
        end

        type   = opts.fetch :type , :single_line
        title  = opts.fetch :title, attr.to_s.humanize
        name   = opts.fetch :scope, "#{attr}_in"
        values = opts.fetch :value, nil

        values   ||= []
        collection = opts[:collection]
        collection = collection.call if collection.respond_to?(:call)

        haml_tag :div, class: 'form-group' do
          haml_concat label(opts[:namespace], name, title)

          haml_tag :div, class: (type == :single_line ? 'form-inline' : 'multi-line') do
            if type == :multi_line
              # Display checked items first
              checked, unchecked = collection.partition {|_, value| values.include?(value.to_s)}

              checked  .each {|label, value| cb(name, label, value, true, opts) }
              haml_tag :hr if checked.present?
              unchecked.each {|label, value| cb(name, label, value, false, opts)}
            else
              collection.each do |label, value|
                cb(name, label, value, values.include?(value.to_s), opts)
              end
            end
          end

        end
      end
    end
  end
end
