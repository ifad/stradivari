module Stradivari
  module Table
    class Builder::ActionBuilder < Builder
      def self.render
        lambda do |object, _, opts|
          actions = opts.fetch(:actions, [:edit, :delete])

          capture_haml do 
            haml_concat link_to("<i class='fa fa-info'></i>".   html_safe, object,
                     class: "btn btn-info btn-xs",    title: 'Show')   if actions.include?(:show)
            haml_concat link_to("<i class='fa fa-edit'></i>".   html_safe, [:edit, object],
                     class: "btn btn-primary btn-xs", title: 'Edit')   if actions.include?(:edit)
            haml_concat link_to("<i class='fa fa-trash-o'></i>".html_safe, object,
                     method: :delete, data: {confirm: "Do you want to remove this entity?"},
                     class: "btn btn-danger btn-xs",  title: 'Delete') if actions.include?(:delete)
          end
        end
      end
    end
  end
end
