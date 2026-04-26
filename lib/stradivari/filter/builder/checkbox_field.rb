module Stradivari
  module Filter
    class Builder::CheckboxField < Builder
      def self.render
        lambda do |attr, opts|
          # rubocop:disable Lint/NestedMethodDefinition -- defined on the view via instance_exec; refactoring to a lambda would change call semantics for descendants
          def cb(name, label, value, checked, opts)
            content_tag(:div, class: 'stradivari-filter__choice stradivari-filter__choice--checkbox', data: { stradivari_filter_choice: true }) do
              content_tag(:label, safe_join([
                                              check_box(opts[:namespace], name, { multiple: true, value: value, checked: checked }, value, nil),
                                              label
                                            ]))
            end
          end
          # rubocop:enable Lint/NestedMethodDefinition

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

          choice_list_classes = Stradivari::ClassNames.join(
            'stradivari-filter__choice-list',
            Stradivari::ClassNames.modifier('stradivari-filter__choice-list', type)
          )
          classes = Builder.prepare_classes(opts, choice_list_classes)
          checkboxes = if type == :multi_line
                         checked_boxes = checked.map { |label, value| cb(name, label, value, true, opts) }
                         if checked.present?
                           checked_boxes << content_tag(:div, safe_join([
                                                                          tag.hr,
                                                                          *unchecked.map { |label, value| cb(name, label, value, false, opts) }
                                                                        ]), class: 'stradivari-filter__collapsed', data: { stradivari_filter_collapsible: true })
                         else
                           checked_boxes.concat(unchecked.map { |label, value| cb(name, label, value, false, opts) })
                         end
                       else
                         collection.map do |label, value|
                           cb(name, label, value, values.include?(value.to_s), opts)
                         end
                       end

          concat content_tag(:div, safe_join([
                                               capture { instance_exec(&Helpers.render_title(name, title, opts)) },
                                               hidden_field(opts[:namespace], "#{name}[]", value: ''),
                                               content_tag(:div, safe_join(checkboxes), class: classes)
                                             ]), Builder.field_attributes(opts))
        end
      end

      def self.value(params, name)
        params[name] || params["#{name}_in"]
      end
    end
  end
end
