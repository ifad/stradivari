# frozen_string_literal: true

module Factories
  module_function

  def create_category(name: 'Default')
    Category.create!(name: name)
  end

  def build_widget(attrs = {})
    Widget.new({
      name: 'Acme',
      description: 'A fine widget',
      price: 100,
      active: true,
      kind: 'gadget',
      released_on: Date.new(2024, 1, 15)
    }.merge(attrs))
  end

  def create_widget(attrs = {})
    w = build_widget(attrs)
    w.save!
    refresh_tsv(w)
    w
  end

  def create_widgets(count, &block)
    Array.new(count) do |i|
      attrs = {
        name: "Widget #{i}",
        price: 100 + i,
        kind: Widget::KINDS[i % Widget::KINDS.length],
        active: i.even?,
        released_on: Date.new(2024, 1, 1) + i
      }
      attrs = attrs.merge(yield(i)) if block
      create_widget(attrs)
    end
  end

  # Populate the tsvector column so :full_text scope can be exercised.
  def refresh_tsv(widget)
    ActiveRecord::Base.connection.execute(<<~SQL.squish)
      UPDATE widgets SET tsv = to_tsvector('english',
        coalesce(name,'') || ' ' || coalesce(description,'') || ' ' || coalesce(kind,''))
      WHERE id = #{widget.id}
    SQL
    widget.reload
  end
end
