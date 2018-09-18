module Stradivari
  module Filter
    class Builder::ActionField

      def self.render
        lambda do
          haml_tag :ul, class: 'list-group actions' do
            haml_tag :li, class: 'list-group-item' do
              haml_tag :button, class: 'btn btn-primary btn-sm search' do
                haml_tag :i, '', class: 'fa fa-search'
                haml_concat I18n.t("stradivari.filter.search", default: 'Search')
              end
              haml_tag :button, class: 'btn btn-default btn-sm clear' do
                haml_tag :i, '', class: 'fa fa-times'
                haml_concat I18n.t("stradivari.filter.clear", default: 'Clear')
              end
            end
          end
        end
      end

    end
  end
end
