module Stradivari
  module Table
    class Builder::ActionBuilder < Builder
      def self.render
        lambda do |object, _, opts|
          actions = opts.fetch(:actions, %i[edit delete])

          capture do
            if actions.include?(:show)
              concat link_to(Stradivari::Icons.svg(:info), object,
                             class: 'stradivari-button stradivari-button--info stradivari-button--xs', title: 'Show')
            end
            if actions.include?(:edit)
              concat link_to(Stradivari::Icons.svg(:edit), [:edit, object],
                             class: 'stradivari-button stradivari-button--primary stradivari-button--xs', title: 'Edit')
            end
            if actions.include?(:delete)
              concat link_to(Stradivari::Icons.svg(:delete), object,
                             method: :delete, data: { confirm: 'Do you want to remove this entity?' },
                             class: 'stradivari-button stradivari-button--danger stradivari-button--xs', title: 'Delete')
            end
          end
        end
      end
    end
  end
end
