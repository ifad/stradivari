# Stradivari

![Antonio Stradivari Portrait][logo]

> Antonio Stradivari (Italian pronunciation: [anˈtɔːnjo stradiˈvaːri]; 1644 –
> 18 December 1737) was an Italian luthier and a crafter of string instruments
> such as violins, cellos, guitars, violas, and harps. Stradivari is generally
> considered the most significant and greatest artisan in this field.
>  - http://en.wikipedia.org/wiki/Antonio_Stradivari

## Design

Like Antonio Stradivari built great musical instruments, this Ruby Gem
is a collection of great tools you can play in your Ruby Web App, and
produce the best symphonies ever.

## History

Started off as a replacement of the [Active Admin][] table and filter
generators DSLs, during the development of an enterprise product that
used to rely on Active Admin. It then stood up, started walking, and
grew up on its own. :smile:

## Features

This Gem combines [HAML][] and [Bootstrap 3][] to provide you easy
generators for:

- HTML Tables
- CSV Tables
- XLS Tables
- Tabbed layouts
- Definition Lists
- Filter forms

The filter form generator includes also all controller code boilerplate
to parse submitted form parameters, and model code to define callable
search scopes and safely process the search parameters, thanks to the
useful help from [Ransack][] and [PgSearch][].

Whoa, what a lot of Gems this glues together! :smile:

## Installation

Add to your Gemfile

    gem 'stradivari', github: 'ifad/stradivari'

## Usage

### Table

Given a typical `app/controllers/foo_controller.rb`:

```ruby
class FooController < ApplicationController
  def index
    @foos = Foo.order_by_awesomeness
  end
end
```

You'd have in your `app/views/foo/index.html.haml`:

```haml
= table_for @foos [header_visible: (true|false), body_visible: (true|false), footer_visible: (true|false), downloadable: (:xlsx|:csv)] do
  - column :id
  - column :awesomeness, presence: true
  - column :something_special do |foo|
    - if foo.really_special?
      %strong This is a special Foo!
    - else
      Nothing to foo here.
  - column :lazy_to_translate, title: "Here we go"
```

This will generate the table head, body and foot markup, cycling over
the `@foos` AR collection. Column headings take attribute names using
`t()`, fitting nicely in [Rails' I18n for Active Record][rails-i18n-ar].

Yhe I18n'ed title can be overriden passing the `:title` option to the
`column` generator, as shown above.

### CSV

```haml
= csv_for @foos do
  - column :id
  - column :boolean_field
  - column :name, presence: true, html: {:class => "custom th class"}
  - column :text_field
  - column :string_field, title: "Here we go"
  - column :created_at
```

### XLS

```haml
= xlsx_for @foos do
  - column :id
  - column :boolean_field
  - column :name, presence: true, html: {:class => "custom th class"}
  - column :text_field
  - column :string_field, title: "Here we go"
  - column :created_at
```

### Tabs

```haml
= tabs_for @foos, flavor: (:tabs|:pills|:stacked), counters: (true|false) do |foos|
  - blank do
    .warning Nothing found
  - tab "Tab label", "tab_div_id", foos.scope do
    = render(partial: 'foos', locals: { foos: foos.scope })
```


### Filter

#### Model
#### Controller
#### View

TODO

### Definition Lists

```haml
= details_for @foos[1] do
  - field :id
  - field :boolean_field, title: "custom title"
  - field :name, presence: true, html: {:class => "custom dd class"}
  - field :text_field
  - field :string_field, title: "Here we go"
  - field :created_at
```

## Tests


## License

MIT

## Copyright

&copy; IFAD 2014

## Mission Statement

Organizations that allow you to write Open Source code are just awesome. It's
actually a shame that it's not *mandatory* for public service engineers to
share their code as Open Source - as this should be natural and embodied in
any public service. So, for now, we try to lead this path, delighted to see
remarkable examples such as NASA and ESA who deliver code and data for free.

Information and knowledge wants to be free, and through it we can make a huge
impact in making the world a better place.

  -- vjt  Mon Jun  9 20:21:42 CEST 2014

[logo]:              http://upload.wikimedia.org/wikipedia/commons/c/cd/Antonio_stradivari.jpg
[Bootstrap 3]:       https://github.com/twbs/bootstrap
[Active Admin]:      https://github.com/gregbell/active_admin
[HAML]:              https://github.com/haml/haml
[PgSearch]:          https://github.com/Casecommons/pg_search
[Ransack]:           https://github.com/activerecord-hackery/ransack
[rails-i18n-ar]:     http://guides.rubyonrails.org/i18n.html#translations-for-active-record-models


