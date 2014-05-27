module Table
  class ActionBuilder < Table::BaseBuilder
    def render object, attribute_name, options = {}
      @actions = options[:actions].present? ? options[:actions] : [:edit, :delete]

      [].tap do |a|
        a << link_to("<i class='fa fa-info'></i>".   html_safe, object,
                            class: "btn btn-info btn-xs") if @actions.include?(:show)
        a << link_to("<i class='fa fa-edit'></i>".   html_safe, [:edit, object],
                            class: "btn btn-primary btn-xs") if @actions.include?(:edit)
        a << link_to("<i class='fa fa-trash-o'></i>".html_safe, object, method: :delete, data: {confirm: "Do you want to remove this entity?"},
                            class: "btn btn-danger btn-xs") if @actions.include?(:delete)
      end.compact.join
    end
  end
end
