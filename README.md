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

This Gem combines [HAML][] and [Bootstrap 4][] to provide you easy
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

Add to your app/assets/javascripts/application.js

    //= require stradivari

Add to your app/assets/stylesheets/application.css

    *= require stradivari

Add to your app/controllers/application_controller.rb

    include Stradivari::Controller

Add to your config/initializers/stradivari.rb

    module Stradivari
    end


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
  - row do |attributes,foo|
    attributes[:class] << " foo_#{foo.foo_type}"
    attributes['data-foo-id'] = foo.id
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

The I18n'ed title can be overriden passing the `:title` option to the
`column` generator, as shown above.

If you wish to set custom attributes on the table row itself, the ```row```
 block will pass you a hash of the row attributes and the current object
(`@foos[n]`). You may add or alter the hash contents and these will be
set on the row element. A good use case for this would be if you wanted
to bind a click handler to the row and needed to record the `foo.id` for
an action specific to that object.

If there is no data, the table will be replaced with a div saying
`There is no data.` You can change this in one of two ways - specify a
different message as the no_data option:
```haml
= table_for @foos, no_data: 'There is nothing to see here'
```
or, provide a `no_data` block which will be rendered in place:
```haml
= table_for @foos do
  - no_data do
    There are no entries.
    %a.btn.btn-secondary{ href:'#' } Create
```

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

You can alter the XLS heading and body styles in the header:

```haml
= xlsx_for @foos, heading_style: { font_name: 'Verdana', sz: 15, bg_color: 'c6c6c6' } do
  - column :id
  - column text_field
```

You can also alter the style of each column:

```haml
= xlsx_for @foos do
  - column :id, style: { size: 8, alignment: { horizontal: :right } }
```

Each style is a hash of Axlsx styling parameters. Here is a subset of the Axslx style
parameters that are probably most useful to you:

Parameter     | Example value            | Description
:------------ | :----------------------- | :--------------------------------------
:sz           | 10                       | Font size (point size)
:font_name    | 'Verdana'                | Font to use
:bg_color     | 'c6c6c6c6'               | Background colour of cell (RGB 6-hex code)
:fg_color     | '00000000'               | Foreground colour of cell (RGB 6-hex code)
:alignment    | { horizontal: :center }  | Centred cell alignment
:alignment    | { vertical: :center }    | Vertically centred cell alignment
:alignment    | { wrap_text: true }      | Wrap overflowing text
:b            | true                     | Bold text
:i            | true                     | Italic text
:u            | :double                  | Underline
:strike       | true                     | Strike-through text
:border       | Axlsx::STYLE_THIN_BORDER | Add border to cells

### Tabs

```haml
= tabs_for @foos, flavor: (:tabs|:pills|:stacked), counters: (true|false) do |foos|
  - blank do
    .warning Nothing found
  - tab "Tab label", "tab_div_id", foos.scope, present: (false|true|:force)  do
    = render(partial: 'foos', locals: { foos: foos.scope })
```

When a tab scope is empty, Stradivari will by default not show the tab. You can force the tab to show
with the ```present: true``` option. You can also force the rendering of the tab's content with the option ```present: :force```.

The blank block is rendered in two cases. The first, if the `tabs_for` scope is empty and there are no
tabs with option ```present: true```. The second, if a tab has this option, but its personal scope is
empty.

Tabs can be conditionally rendered using the `if:` option and passing a `lambda` to it. If it evaluates
to a falsish value, the tab is hidden. The block is executed in the view context.

Tab content can be optionally loaded from a remote URL by passing the `url:` option. If you need to use
Rails' route helpers, you have to reach to them through the `view` object, e.g.:

```
tabs_for @foos do
  - tab :bar, url: view.bars_path do
    .loading Loading...
```

When retrieving data from a remote URL, Stradivari will emit events at key lifecycle points:

Event Name             | Extra Parameters | When
:--------------------- | :--------------- | :--------------------------------------
stradivari:tab:loading | none             | Before the AJAX send
stradivari:tab:loaded  | none             | After a successful response is received
stradivari:tab:failed  | none             | After a failed response is received

These events will be emitted on the tab link that was clicked to initiate the remote load.
This is useful if there are actions that must be performed before or after the remote data
is loaded. For example, here is a simple example enabling pagination of a table loaded in
the remote request:

The HAML:

```haml
= tabs_for @foos do |foos|
  - tab "Tab label", "tab_div_id", foos.scope, present: true, url: '/foos' do
    .loading Loading...
```

The partial ```/foos```:

```haml
= table_for @foos do |foos|
  - column :bar
  - column :baz
= paginate @foos, remote: true
```

And finally, some javascript to bind the paginators correctly when the partial loads:

```javascript
function bindPaginators(tab_pane) {
  $('nav.pagination a',tab_pane).on('ajax:success', function(e,data) {
    $(tab_pane).html(data);
    bindPaginators(tab_pane);
  });

$('[data-toggle=tab']).on('stradivari:tab:loaded', function(evt) {
  var tab_id = $(this).attr('href'); // href of the <a> element is "#tab_div_id"
  bindPaginators( $(tab_id) ); // $('#tab_div_id')
});
```

#### Dislocated tabs

The tabbed examples above place some constraints on how you lay out the tabs. It
groups both the nav and the content under the same container. In some cases, you
may wish to separatethe nav from the content. The ```tab_navs_for``` and
```tab_content_for``` helper methods allow this:

```haml
  .row
    .col-xs-3
      = tab_navs_for @people, flavor: :stacked do |people|
        - tab 'Option 1', 'option_1_id', people.foos, active: true
        - tab 'Option 2', 'option_2_id', people.bars
    .col-xs-3
      = tab_content_for @people do |people|
        - tab_content 'option_1_id', people.foos, active: true do |scope|
          This is content for option 1
        - tab_content 'option_2', people.bars do |scope|
          This is content for option 2
```

`tab_navs_for` takes the same options as `tabs_for`, as does its `tab` method,
which does not take a block, however. Instead, the block is present in the `tab`
option of `tab_content_for`. It is important both that the ID fields match
between the two `tab` methods and that the scopes do as well, otherwise there
may be display issues. You also have to set ```active: true``` on the content
tab as well as the nav tab.

#### How to specify opened tabs at page load

You can specify which tabs to automatically open at the page loading adding their id to the parameter `stradi_tabs[]=` to the page URI. Multiple tabs can be specified.

es: http://mysite.com?stradi_tabs[]=bar&stradi_tabs[]=baz

### Filter

Stradivari uses Ransack to perform search queries. Ransack provides a mapper
that transforms form parameters into an ActiveRecord Relation query, using
_predicates_ such as `id_eq` or `name_cont`. For details about Ransack's
predicates syntax, [please have a look here][ransack-basic-searching].

To compose the search query for a model, Stradivari extends ActiveRecord with
a `stradivari_filter` method that is available in your models.

The user-provided search query is available in your controller through the
`stradivari_filter_options` method.

Stradivari provides a set of filter builders that you can (should) use to
create your filter forms.

TODO: Stradivari is based on a (as of 04/2015) legacy version of Ransack,
extending it to add functions that are now available upstream - so this
should be fixed.

#### Model

Given this data model:

    # db/schema.rb
    create_table :posts do |t|
      t.integer :author_id
      t.string  :title
      t.text    :body
      t.timestamps
    end

By default, with no changes to the model, you can already search on all model
fields using Ransack features. Supposing you also have a specific scope you
want to search on, you can define it in your model:

    # app/models/post.rb
    class Post < ActiveRecord::Base
      belongs_to :author

      stradivari_scope :by_author_name do |user_provided_input|
        joins(:author).where("authors.name LIKE ?", user_provided_input)
      end
    end

`Post.by_author_name` behaves like every other ActiveRecord scope, and it is
also marked accessible through user-provided search queries. *Always be
careful with user provided input*. Stradivari or ActiveRecord can't protect
you from shooting yourself in the foot if you want to. Follow the Robustness
principle: _Be conservative in what you do, be liberal in what you accept_.

#### View

Let's then define a posts list table with some filters.

```haml
    / app/views/posts/index.html.haml

    = table_for @posts do
      - column :author do |post|
        = post.author.name
      - column :title
      - column :body do |post|
        = truncate(post.body, length: 140)
      - column :created_at
      - column :updated_at

    = filter_for Post do
      - selection :author_id, collection: Author.all
      - search :title
      - search :body
      - date_range :created_at
      - search :by_author_name
```

Behind the scenes, Stradivari builds an appropriate Ransack predicate for each
builder, and builds the search form. Each builder has its own options and
tweaks, [see the source for now for more information][src-filter-builder].

In this case, the `title` and `body` attribute will generate a `title_cont`
Ransack predicate that will be translated to a `SQL LIKE` operator, while the
`by_author_name` field will pass along the user provided input to the
corresponding `stradivari_scope` method defined on the `Post` model.

#### Controller

Start by adding `Stradivari::Controller` to your `ApplicationController`

    # app/controllers/application_controller.rb
    module ApplicationController
      include Stradivari::Controller
    end

Then, in your `PostsController`

    # app/controllers/posts_controller.rb
    class PostsController < ApplicationController
      def index
        @posts = stradivari_filter(Post)
      end
    end

`@posts` is an `ActiveRecord::Relation` that can be further manipulated,
paginated, etc.

`stradivari_filter` is both the name of a controller helper, that accepts
an ActiveRecord object (either a model or a Relation) and that invokes the
search machinery, using as parameters the hash representation of the `q`
query string parameter.

Stradivari defines also a `.stradivari_filter` method on your models, that
behaves like a standard Active Record scope. It accepts and hash, that are
the search parameters. You can pass your own hash, or you can get it from
the query string using `stradivari_filter_options`.

The following two calls are identical:

    stradivari_filter(Post)
    Post.stradivari_filter(stradivari_filter_options)

The latter is useful if you want to massage the filter options yourself,
or if you want to have a pure scopes chain - matter of taste.

The return value of `.stradivari_filter_options` is an Hash and can be
manipulated as you see fit.

#### Sorting

To enable sorting support, currently Stradivari has a constraint on one model
per controller. If you manage multiple models with the same controller (and
you shouldn't ;-) then you can use sorting functions only on one of them.

The model can be defined in your controller by overriding the
`sorting_object_class` method. By default, Stradivari will try to infer the
model name from the controller name, e.g. a PostsController will try to find a
Post model, but if this fail then it's up to you to define it. Example:

    # app/controllers/posts_controller.rb
    class PostsController
      # [ ... ]
      protected

      def sorting_object_class
        Post
      end
    end

Default sort column and direction are, respectively, `id` and `ASC`. To
override them, you can override the `default_sort_column` and
`default_sort_direction` methods.

If we would want to display most recent posts first, for example, we could
use:

    # app/controllers/posts_controller.rb
    class PostsController
      def default_sort_column
        'created_at'
      end

      def default_sort_direction
        'DESC'
      end
    end

Alternatively, you can define sort parameters using the `stradivari_filter`
DSL method:

    stradivari_filter Post,
      default_sorting:   'created_at',
      default_direction: 'DESC'

Ransack provides basic sorting options for column names. The `title` column in
the above example can be made sortable in the rendered table by adding the
`sortable: true` option:

    = table_for @posts do
      - column :title, sortable: true

For more complex sorting schemes, e.g. if we want to sort on the associated
author name, we have to define the sorting semantics in the model first.

Stradivari looks up a `scope` in the model named after the column with a
`sort_by` prefix and `asc` or `desc` as suffix. In this example, this would
be:

    class Post < ActiveRecord::Base
      scope :sort_by_author_asc,  -> { joins(:author).order('authors.name ASC') }
      scope :sort_by_author_desc, -> { joins(:author).order('authors.name DESC') }
    end

    = table_for @posts do
      - column :author, sortable: true do |post|
        = post.author.name

You can pass to the `sortable` option the scope name you want to use, e.g. if
you called the above scope `sort_by_person_asc`, you would have needed to
specify `sortable: person`. This is useful when reusing these scopes for
multiple purposes.

#### Detached form

TODO

#### Full-text search

TODO

#### Prepending elements to the search form

    - prepend(class: "options") do
      %p This is a prepended text

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

### Stradivari Autocompleter

If you want to use the Stradivari Autocomplete, please add
[twitter-typeahead-rails](https://github.com/yourabi/twitter-typeahead-rails) to your project

The stradivari Autocompleter uses both the detached form and the form filters

It will use the keys in the filters to generate a list of autocomplete terms
in the detached form

When you select a term from the autocomplete list, the corresponding filter is
automagically selected in the filter list


To enable it, put the autocomplete:true option in the detached form search field

  - search :matching, title: 'Search', class: "focus", autocomplete: true

The class "focus" is used to give default focus to the search field

Then, on the checkbox fields in the filter, use the autocomplete: true option
to tell to the Stradivari to grab that list and use it in the Autocompleter

- checkbox :foo, collection: Foo.foos, priority: :low, title: "Foo", autocomplete: true


## Tests


## License

MIT

## Copyright

&copy; IFAD 2014-2015

## Denominazione d'Origine Controllata

This software is Made in Italy :it: :smile:.

## Mission Statement

Organizations that allow you to write Open Source code are just awesome. It's
actually a shame that it's not *mandatory* for public service engineers to
share their code as Open Source - as this should be natural and embodied in
any public service. So, for now, we try to lead this path, delighted to see
remarkable examples such as NASA and ESA who deliver code and data for free.

Information and knowledge wants to be free, and through it we can make a huge
impact in making the world a better place.

  -- vjt  Mon Jun  9 20:21:42 CEST 2014

[logo]:                    http://upload.wikimedia.org/wikipedia/commons/c/cd/Antonio_stradivari.jpg
[Bootstrap 4]:             https://getbootstrap.com/docs/4.6/getting-started/introduction/
[Active Admin]:            https://github.com/gregbell/active_admin
[HAML]:                    https://github.com/haml/haml
[PgSearch]:                https://github.com/Casecommons/pg_search
[Ransack]:                 https://github.com/activerecord-hackery/ransack
[rails-i18n-ar]:           http://guides.rubyonrails.org/i18n.html#translations-for-active-record-models
[ransack-basic-searching]: https://github.com/activerecord-hackery/ransack/wiki/Basic-Searching
[src-filter-builder]:      https://github.com/ifad/stradivari/tree/master/lib/filter/builder
