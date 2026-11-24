# Changelog

## 0.8.0

This release refactors the gem and is **not backward compatible**.

* [BREAKING] Requires Ruby 3.2 or later and Rails 7.2, 8.0 or 8.1. Older Rails versions are no longer supported.
* [BREAKING] The Haml dependency is removed. The helpers use plain Rails view helpers and work in ERB, Haml or Slim.
* [BREAKING] The LESS and Bootstrap stylesheets are replaced by `stradivari.css`, plain CSS generated from Tailwind CSS. Host applications need neither Bootstrap nor Tailwind. Themes that target Bootstrap classes must target the `stradivari-*` classes instead (see the README).
* [BREAKING] The generated markup uses `stradivari-*` BEM classes only. Bootstrap classes such as `dl-horizontal` are no longer rendered.
* [BREAKING] jQuery is removed. The JavaScript is plain browser code, `base.js.erb` is now `base.js` and the autocompleter is dropped. Tabs emit the same `stradivari:tab:*` events as native DOM events, so `$(...).on(...)` handlers no longer fire; use `addEventListener`.
* [FEATURE] Selection filters accept `multiple: true`, which renders a multi-select and filters with `_in`.
* [ENHANCEMENT] The table header shows the sort icon only on sortable columns.
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
