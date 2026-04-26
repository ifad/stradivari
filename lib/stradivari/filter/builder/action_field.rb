module Stradivari
  module Filter
    class Builder::ActionField
      def self.render
        lambda do
          search = content_tag(:button, safe_join([content_tag(:i, '', class: 'fa fa-search'), ' Search']),
                               class: 'btn btn-primary btn-sm search')
          clear = content_tag(:button, safe_join([content_tag(:i, '', class: 'fa fa-times'), ' Clear']),
                              class: 'btn btn-default btn-sm clear')

          concat content_tag(:ul, content_tag(:li, safe_join([search, clear]), class: 'list-group-item'),
                             class: 'list-group actions')
        end
      end
    end
  end
end
