require 'filter/helpers'

module Filter
  class SelectionFieldBuilder

    def self.render
      lambda do |_, attr, opts|
        collection = opts[:collection].is_a?(Proc) ? opts[:collection].call : opts[:collection]
        title      = opts.fetch(:title, attr.to_s.humanize)
        attr       = opts[:is_scoped] ? attr : [attr, 'eq'].join('_')

        haml_tag :div, class: 'form-group' do
          haml_concat label(opts[:namespace], attr, title)

          if collection.kind_of?(Array) && collection.size <= 5
            instance_exec(&Helpers.radios_for_collection(collection, attr, opts))

          else
            haml_concat select(opts[:namespace], attr, collection, {selected: opts[:value], include_blank: 'Any'}, {class: 'form-control'})
          end
        end
      end
    end

  end
end
