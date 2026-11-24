# Changelog

## 0.8.0

This release refactors the gem and is **not backward compatible**.

* [BREAKING] Requires Ruby 3.2 or later and Rails 7.2, 8.0 or 8.1. Older Rails versions are no longer supported.
* [BREAKING] The Haml dependency is removed. The helpers use plain Rails view helpers and work in ERB, Haml or Slim. Applications with Haml views must add `haml` to their own Gemfile.
* [BREAKING] The LESS and Bootstrap stylesheets are replaced by `stradivari.css`, plain CSS generated from Tailwind CSS. Host applications need neither Bootstrap nor Tailwind. Themes that target Bootstrap classes must target the `stradivari-*` classes instead (see the README).
* [BREAKING] The generated markup uses `stradivari-*` BEM classes only. Bootstrap classes such as `dl-horizontal` are no longer rendered. The Stradivari classes that scripts and styles may target are renamed too: `filter-form-container`, `filter-form` and `form-detached` are now `stradivari-filter`, `stradivari-filter__form` and `stradivari-filter__form--detached`; the `parent` and `child` rows are `stradivari-table__row--parent` and `stradivari-table__row--child`; the `sortable` and `active-column` header cells are `stradivari-table__header-cell--sortable` and `stradivari-table__header-cell--active`; the `downloadable_event` link is `stradivari-table__download-link--event`.
* [BREAKING] The `table.selectable`, `tr.selected` and `.select` rules and the `.dl-horizontal` styles are removed from the stylesheet. Applications that relied on them must supply their own CSS.
* [BREAKING] The stylesheet sets `color-scheme: light dark` on Stradivari markup instead of the page root, so a dark system theme no longer switches the host page's own background, text, form controls and scrollbars. Active tab panes now use the Stradivari text color.
* [BREAKING] The stylesheet no longer defines Tailwind's `--spacing`, `--text-*`, `--font-weight-*` and `--leading-*` variables or the `--tw-*` properties, and its cascade layers are `stradivari.theme`, `stradivari.components` and `stradivari.utilities` instead of `theme`, `components` and `utilities`. Its Tailwind variables are `--stradivari-spacing`, `--stradivari-text-sm` and so on, so it no longer collides with or reorders a host's Tailwind v4 build. Stradivari rules no longer join the host's `components` layer: to keep the host's utilities above them and its preflight below them, declare `@layer theme, base, stradivari, components, utilities;` before either stylesheet loads.
* [BREAKING] Font Awesome markup is replaced by inline SVG icons with the `stradivari-icon` class, and the column `sortable_icon:` option is dropped.
* [BREAKING] Plain strings that are not `html_safe` are HTML-escaped wherever Stradivari renders them: column block results, column titles, tab labels and the `no_data:` message. Column block results used to be output as HTML. Return `html_safe` strings or tag helper output to render markup.
* [BREAKING] `include_blank: false` now removes the `Any` option from a selection `<select>`, which always had it before.
* [BREAKING] jQuery is removed. The JavaScript is plain browser code, `base.js.erb` is now `base.js` and the autocompleter is dropped. Tabs emit the same `stradivari:tab:*` events as native DOM events.
* [BREAKING] The `stradivari:download` event carries the clicked link in `event.detail.element` instead of the second handler argument.
* [BREAKING] `$.fn.filterSelect` is replaced by `Stradivari.filterSelect(selector, options)`.
* [BREAKING] Tabs no longer use Bootstrap: tab links have `data-stradivari-tab` instead of `data-toggle="tab"`, and no `shown.bs.tab` event is fired.
* [BREAKING] `Stradivari::Filter::TYPEAHEAD_DISPLAY_NAME`, `Stradivari::Filter::TYPEAHEAD_VALUE_NAME`, and the JavaScript `Stradivari.typeaheadDisplay`, `Stradivari.typeaheadValue` and `Stradivari.version` are removed. Search fields ignore `autocomplete: true`.
* [FEATURE] Selection filters accept `multiple: true`, which renders a multi-select and filters with `_in`.
* [ENHANCEMENT] `details_for` renders `stradivari-details` and keeps the class passed by the caller.
* [ENHANCEMENT] The gemspec declares `actionpack` and `railties`.

## 0.7.1

* [FEATURE] Support for rails 7 ([#30](https://github.com/ifad/stradivari/pull/37))

## 0.7.0

* [FEATURE] Replace axlsx with caxlsx ([#25](https://github.com/ifad/stradivari/issues/25))

## 0.6.3

* [BUGFIX] Fix blank option and default checked value ([#31](https://github.com/ifad/stradivari/issues/31))

## 0.6.2

* [FEATURE] Add options to specify blank option and default checked value ([#29](https://github.com/ifad/stradivari/pull/29))

## 0.6.1

* [ENHANCEMENT] PgSearch Fix deprecation warning ([#28](https://github.com/ifad/stradivari/pull/28))

## 0.6.0

* [FEATURE] Rails 6 Support ([#27](https://github.com/ifad/stradivari/pull/27))
