# frozen_string_literal: true

module Stradivari
  module Table
    class Builder::ActionBuilder < Builder
      def self.render
        lambda do |object, _, opts|
          actions = opts.fetch(:actions, %i[edit delete])

          capture_haml do
            if actions.include?(:show)
              haml_concat link_to("<span class='fas fa-info' aria-hidden='true'></span>".html_safe, object,
                                  class: 'btn btn-info btn-sm',    title: 'Show')
            end
            if actions.include?(:edit)
              haml_concat link_to("<span class='fas fa-edit' aria-hidden='true'></span>".html_safe, [:edit, object],
                                  class: 'btn btn-primary btn-sm', title: 'Edit')
            end
            if actions.include?(:delete)
              haml_concat link_to("<span class='fas fa-trash' aria-hidden='true'></span>".html_safe, object,
                                  method: :delete, data: { confirm: 'Do you want to remove this entity?' },
                                  class: 'btn btn-danger btn-sm', title: 'Delete')
            end
          end
        end
      end
    end
  end
end
