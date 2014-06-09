# Stradivari

![Antonio Stradivari Portrait][logo]

> Antonio Stradivari (Italian pronunciation: [anˈtɔːnjo stradiˈvaːri]; 1644 –
> 18 December 1737) was an Italian luthier and a crafter of string instruments
> such as violins, cellos, guitars, violas, and harps. Stradivari is generally
> considered the most significant and greatest artisan in this field.
>  - http://en.wikipedia.org/wiki/Antonio_Stradivari

## Design

Like Antonio Stradivari built great musical instruments, this Ruby Gem is a
collection of great tools for your Ruby Web Application.

## History

Started off as a replacement of the [Active Admin](https://github.com/gregbell/active_admin) 
table and filter generators DSL, during the development of an enterprise product 
that used to rely on Active Admin, it grew up on its own.

## Features

This Gem combines [HAML](https://github.com/haml/haml) and
[Bootstrap 3](https://github.com/twbs/bootstrap) to provide you easy generators for:

- HTML Tables
- CSV Tables
- Tabbed layouts
- Definition Lists
- Filter forms

The filter form generator includes also all controller code boilerplate to
parse the form parameters, and model code to define search scopes and process
the search parameters - leveraging [Ransack](https://github.com/activerecord-hackery/ransack)
and [PgSearch](https://github.com/Casecommons/pg_search).

Whoa, what a lot of Gems this glues together! :smile:

## Installation

Add to your Gemfile

    gem 'stradivari', github: 'ifad/stradivari'

## Usage

TODO! Yes, TODO. By example, it'll follow soon in this very README file.

## Tests

TODO! Yes, **really** TODO. Wanna help? Please send a pull req!

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

[logo]: http://upload.wikimedia.org/wikipedia/commons/c/cd/Antonio_stradivari.jpg
