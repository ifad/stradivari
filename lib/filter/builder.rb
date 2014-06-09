module Filter

  class Builder
    Implementations = {
      selection:  'SelectionField',
      date_range: 'DateRangeField',
      number:     'NumberField',
      boolean:    'BooleanField',
      checkbox:   'CheckboxField',
      search:     'SearchField'
    }

    Implementations.each do |id, name|
      require "filter/builder/#{id}_field"
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
