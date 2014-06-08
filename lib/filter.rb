module Filter
  autoload :ActionFieldBuilder,         'filter/action_field_builder'
  autoload :BooleanFieldBuilder,        'filter/boolean_field_builder'
  autoload :CheckboxFieldBuilder,       'filter/checkbox_field_builder'
  autoload :DateRangeFieldBuilder,      'filter/date_range_field_builder'
  autoload :Generator,                  'filter/generator'
  autoload :NumberFieldBuilder,         'filter/number_field_builder'
  autoload :SearchFieldBuilder,         'filter/search_field_builder'
  autoload :SelectionFieldBuilder,      'filter/selection_field_builder'

  NAMESPACE = :q
end
