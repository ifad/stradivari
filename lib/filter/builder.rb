module Filter

  class Builder
    Implementations = {
      selection_field:  'SelectionField',
      date_range_field: 'DateRangeField',
      number_field:     'NumberField',
      boolean_field:    'BooleanField',
      checkbox_field:   'CheckboxField',
      search_field:     'SearchField'
    }

    Implementations.each do |id, name|
      require "filter/builder/#{id}"
      Implementations[id] = const_get(name)
    end.freeze

    autoload :ActionField, 'filter/builder/action_field'

    def self.render
      raise NotImplementedError
    end

    def self.value(params, name)
      params[name] || params["#{name}_eq"]
    end

    def self.active?(params, name)
      value(params, name).present?
    end
  end

end
