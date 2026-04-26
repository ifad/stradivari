module Stradivari
  module Filter
    class Builder::SearchField < Builder
      def self.render
        lambda do |attr, opts|
          attr = [attr, 'cont'].join('_') unless opts[:is_scoped]

          title = opts[:title] || "Search #{attr.to_s.humanize}"
          placeholder = opts[:placeholder] || title

          data = {}

          data[:stradivari] = 'autocomplete' if opts.fetch(:autocomplete, false)

          if (d = opts.fetch(:data, nil).presence)
            if (u = d.fetch(:remote_url, nil).presence)
              data['remote-url'] = u
            end

            if (l = d.fetch(:display, nil).presence)
              data['display'] = l.call(opts[:value])
            end
          end

          if (sort = opts.fetch(:sort, nil))
            data[:sort] = sort
          end

          input_options = { value: opts[:value], class: Stradivari::ClassNames.join(opts[:class], 'stradivari-control'), placeholder: placeholder, data: data }

          warn "The skip_button option to search filter field is deprecated. Please use button: true/false. Button is now disabled by default. (called from #{caller(1..1).first})" if opts.key?(:skip_button)

          body = if opts[:skip_button] || !opts.fetch(:button, nil)
                   safe_join([
                               capture { instance_exec(&Helpers.render_title(attr, title.clone, opts)) },
                               content_tag(:div, text_field(opts[:namespace], attr, input_options), Builder.control_attributes(opts, 'stradivari-filter__search'))
                             ])
                 else
                   content_tag(:div, class: 'stradivari-input-group') do
                     safe_join([
                                 text_field(opts[:namespace], attr, input_options),
                                 content_tag(:span, class: 'stradivari-input-group__action') do
                                   content_tag(:button,
                                               type: 'button',
                                               class: 'stradivari-button stradivari-button--primary stradivari-button--search',
                                               data: { stradivari_filter_action: 'search' }) do
                                     safe_join([Stradivari::Icons.svg(:search), 'Search'])
                                   end
                                 end
                               ])
                   end
                 end

          concat content_tag(:div, body, Builder.field_attributes(opts))
        end
      end

      def self.value(params, name)
        params[name] || params["#{name}_cont"]
      end
    end
  end
end
