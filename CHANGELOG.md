# Changelog

## 0.8.0

* [FEATURE] Support Rails 8.1 + Ruby 4.0 — filter-model adapter now defaults to
  the modern (Rails 4+) path instead of enumerating each major and raising on
  anything newer than Rails 7.
* [FEATURE] Haml 6+ support. `haml_tag` / `haml_concat` / `capture_haml` were
  removed from `Haml::Helpers` in Haml 6; the gem now ships its own
  `Stradivari::HamlCompat` (over ActionView's `content_tag` / `capture`) mixed
  into the view via `StradivariHelper`, so consumers no longer need an app-side
  shim.
* [BUGFIX] Don't `NameError` at boot when ActionMailer isn't loaded (api_only
  apps): the helper-injection hook now guards `ActionController::Base` /
  `ActionMailer::Base` with `defined?`.
* [CHORE] Drop the `bundler "~> 1.5"` development pin; add `required_ruby_version
  >= 3.0`; add a smoke harness (`test/smoke.rb` + `Dockerfile.ai`) and a CI
  matrix (Ruby 3.4/4.0 × Rails 7.2/8.1) — the gem had no automated tests.

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
