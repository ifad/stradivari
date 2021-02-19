# frozen_string_literal: true

module Stradivari
  module Filter
    class Builder::ActionField
      def self.render
        lambda do
          haml_tag :div, class: 'list-group-item list-group-item--stradivari' do
            haml_tag :button, class: 'btn btn-primary btn-sm btn--stradivari-search' do
              haml_tag :span, '', class: 'fas fa-search', 'aria-hidden' => 'true'
              haml_concat ' Search'
            end
            haml_tag :button, class: 'btn btn-secondary btn-sm btn--stradivari-clear' do
              haml_tag :span, '', class: 'fas fa-times', 'aria-hidden' => 'true'
              haml_concat ' Clear'
            end
          end
        end
      end
    end
  end
end
