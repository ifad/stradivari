module Stradivari
  module Filter
    class Builder::ActionField
      def self.render
        lambda do
          search = content_tag(:button, safe_join([Stradivari::Icons.svg(:search), ' Search']),
                               type: 'button',
                               class: 'stradivari-button stradivari-button--primary stradivari-button--sm stradivari-button--search',
                               data: { stradivari_filter_action: 'search' })
          clear = content_tag(:button, safe_join([Stradivari::Icons.svg(:clear), ' Clear']),
                              type: 'button',
                              class: 'stradivari-button stradivari-button--secondary stradivari-button--sm stradivari-button--clear',
                              data: { stradivari_filter_action: 'clear' })

          concat content_tag(:ul, content_tag(:li, safe_join([search, clear]), class: 'stradivari-filter__action-item'),
                             class: 'stradivari-filter__actions')
        end
      end
    end
  end
end
