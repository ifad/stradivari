ActiveRecord::Schema.define do
  enable_extension 'plpgsql' rescue nil

  create_table :categories, force: true do |t|
    t.string :name, null: false
    t.timestamps
  end

  create_table :widgets, force: true do |t|
    t.string  :name,        null: false
    t.text    :description
    t.integer :price,       default: 0
    t.boolean :active,      default: true
    t.string  :kind
    t.date    :released_on
    t.references :category, foreign_key: true
    t.tsvector :tsv
    t.timestamps
  end

  add_index :widgets, :tsv, using: :gin
  add_index :widgets, :kind
end
