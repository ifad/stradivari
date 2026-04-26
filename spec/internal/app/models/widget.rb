class Widget < ActiveRecord::Base
  belongs_to :category, optional: true

  KINDS = %w[gadget gizmo widget].freeze

  # Filter scopes (declared via Stradivari::Filter::Model)
  stradivari_scope :name_like, ->(value) { where('name ILIKE ?', "%#{value}%") }
  stradivari_scope :kind, ->(value) { where(kind: value) }, type: :selection
  stradivari_scope :active, ->(value) { where(active: value) }, type: :boolean
  stradivari_scope :priced_above, ->(value) { where('price > ?', value.to_i) }, type: :number
  stradivari_scope :search, type: :full_text, dictionary: :english, column: 'tsv'

  # Sort scopes (Table::Model::Base.sortable_by? recognizes sort_by_<x>_<dir>)
  scope :sort_by_name_asc,  -> { order(name: :asc) }
  scope :sort_by_name_desc, -> { order(name: :desc) }

  # Ransack 4 requires explicit allow-lists.
  def self.ransackable_attributes(_auth_object = nil)
    %w[id name description price active kind released_on category_id created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[category]
  end
end
