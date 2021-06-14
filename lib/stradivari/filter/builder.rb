# frozen_string_literal: true

module Stradivari
  module Filter
    class Builder < Stradivari::Builder
      IMPLEMENTATIONS = {
        selection: 'SelectionField',
        date_range: 'DateRangeField',
        number: 'NumberField',
        boolean: 'BooleanField',
        checkbox: 'CheckboxField',
        search: 'SearchField',
        custom: 'CustomField'
      }

      IMPLEMENTATIONS.each do |id, name|
        require "stradivari/filter/builder/#{id}_field"
        IMPLEMENTATIONS[id] = const_get(name)
      end.freeze

      autoload :ActionField, 'stradivari/filter/builder/action_field'

      class << self
        def value(params, name)
          params[name] || params["#{name}_eq"] || params["#{name}_in"]
        end

        def active?(params, name)
          Array.wrap(value(params, name)).select(&:present?).present?
        end

        def prepare_classes(opts, classes = '')
          classes = classes.dup
          classes << " stradivari-options stradivari-options--#{priority(opts)}-priority"
          classes << ' collapse collapse--stradivari' if priority(opts) == :low && !opts[:active_field]
          classes
        end

        def priority(opts = {})
          opts.fetch :priority, :normal # :low, :normal, :high
        end
      end
    end
  end
end
