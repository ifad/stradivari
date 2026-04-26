module Stradivari
  module Icons
    SEARCH = '<svg class="stradivari-icon" aria-hidden="true" focusable="false" viewBox="0 0 16 16" width="16" height="16"><circle cx="7" cy="7" r="4.5" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M10.5 10.5 14 14" fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="1.5"/></svg>'.freeze
    CLEAR = '<svg class="stradivari-icon" aria-hidden="true" focusable="false" viewBox="0 0 16 16" width="16" height="16"><path d="m4.5 4.5 7 7M11.5 4.5l-7 7" fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="1.5"/></svg>'.freeze
    INFO = '<svg class="stradivari-icon" aria-hidden="true" focusable="false" viewBox="0 0 16 16" width="16" height="16"><circle cx="8" cy="8" r="6" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M8 7.25v4" fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="1.5"/><circle cx="8" cy="4.75" r=".75" fill="currentColor"/></svg>'.freeze
    EDIT = '<svg class="stradivari-icon" aria-hidden="true" focusable="false" viewBox="0 0 16 16" width="16" height="16"><path d="M3 11.5 2.5 14l2.5-.5 7.7-7.7a1.7 1.7 0 0 0-2.4-2.4L3 11.5Z" fill="none" stroke="currentColor" stroke-linejoin="round" stroke-width="1.5"/><path d="m9.25 4.45 2.3 2.3" fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="1.5"/></svg>'.freeze
    DELETE = '<svg class="stradivari-icon" aria-hidden="true" focusable="false" viewBox="0 0 16 16" width="16" height="16"><path d="M3 4.5h10M6.25 4.5V3h3.5v1.5M5 6l.5 7h5L11 6" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"/></svg>'.freeze
    SORT = '<svg class="stradivari-icon" aria-hidden="true" focusable="false" viewBox="0 0 16 16" width="16" height="16"><path d="m5 3 3-2.5L11 3M8 .5v15M5 13l3 2.5 3-2.5" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"/></svg>'.freeze
    SORT_ASC = '<svg class="stradivari-icon" aria-hidden="true" focusable="false" viewBox="0 0 16 16" width="16" height="16"><path d="m5 5 3-3 3 3M8 2v12" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"/></svg>'.freeze
    SORT_DESC = '<svg class="stradivari-icon" aria-hidden="true" focusable="false" viewBox="0 0 16 16" width="16" height="16"><path d="M5 11l3 3 3-3M8 2v12" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5"/></svg>'.freeze

    ICONS = {
      clear: CLEAR,
      delete: DELETE,
      edit: EDIT,
      info: INFO,
      search: SEARCH,
      sort: SORT,
      sort_asc: SORT_ASC,
      sort_desc: SORT_DESC
    }.freeze

    module_function

    def svg(name)
      markup = ICONS.fetch(name.to_sym, SORT)
      defined?(ActiveSupport::SafeBuffer) ? ActiveSupport::SafeBuffer.new(markup) : markup
    end
  end
end
