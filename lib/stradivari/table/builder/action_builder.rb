module Stradivari
  module Table
    class Builder::ActionBuilder < Builder
      def self.render
        lambda do |object, _, opts|
          actions = opts.fetch(:actions, %i[edit delete])

          capture do
            if actions.include?(:show)
              concat link_to("<i class='fa fa-info'></i>".html_safe, object,
                             class: 'btn btn-info btn-xs',    title: 'Show')
            end
            if actions.include?(:edit)
              concat link_to("<i class='fa fa-edit'></i>".html_safe, [:edit, object],
                             class: 'btn btn-primary btn-xs', title: 'Edit')
            end
            if actions.include?(:delete)
              concat link_to("<i class='fa fa-trash-o'></i>".html_safe, object,
                             method: :delete, data: { confirm: 'Do you want to remove this entity?' },
                             class: 'btn btn-danger btn-xs', title: 'Delete')
            end
          end
        end
      end
    end
  end
end
