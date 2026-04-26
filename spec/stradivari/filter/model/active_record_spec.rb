require 'spec_helper'

RSpec.describe Stradivari::Filter::Model::ActiveRecord, type: :model do
  before do
    create_widgets(5)
  end

  describe '.stradivari_filter' do
    it 'applies a custom string scope (name_like)' do
      result = Widget.stradivari_filter('name_like' => 'Widget 2')
      expect(result.to_a.map(&:name)).to eq(['Widget 2'])
    end

    it 'coerces boolean scope values from strings' do
      result = Widget.stradivari_filter('active' => 'true')
      expect(result.to_a.size).to be_positive
      expect(result.to_a.map(&:active).uniq).to eq([true])
    end

    it 'applies number-typed scope' do
      result = Widget.stradivari_filter('priced_above' => '102')
      expect(result.to_a.map(&:price)).to all(be > 102)
    end

    it 'discards blank values' do
      result = Widget.stradivari_filter('name_like' => '')
      expect(result.count).to eq(Widget.count)
    end

    it 'discards arrays of blanks' do
      result = Widget.stradivari_filter('name_like' => ['', nil])
      expect(result.count).to eq(Widget.count)
    end

    it 'sorts by a known sort_by_<col>_<dir> scope' do
      result = Widget.stradivari_filter(sort: 'name', direction: 'asc')
      expect(result.to_a.map(&:name)).to eq(Widget.order(name: :asc).pluck(:name))
    end

    it 'falls back to ransack sort when no sort_by_ scope exists' do
      result = Widget.stradivari_filter(sort: 'price', direction: 'desc')
      expect(result.to_a.map(&:price)).to eq(Widget.order(price: :desc).pluck(:price))
    end

    it 'applies ransack predicates passed at the top level' do
      result = Widget.stradivari_filter('price_gt' => 102)
      expect(result.to_a.map(&:price)).to all(be > 102)
    end
  end

  describe '.stradivari_scopes registry' do
    it 'records each declared scope with its options' do
      registry = Widget.stradivari_scopes
      expect(registry).to include(:name_like, :kind, :active, :priced_above, :search)
      expect(registry[:active][:type]).to eq(:boolean)
      expect(registry[:priced_above][:type]).to eq(:number)
      expect(registry[:kind][:type]).to eq(:selection)
      expect(registry[:search][:type]).to eq(:full_text)
    end

    it 'is inherited by subclasses (deep copy semantics)' do
      sub = Class.new(Widget)
      expect(sub.stradivari_scopes).to include(:name_like)
    end
  end

  describe 'full-text search via pg_search' do
    it 'returns matching rows when the tsvector contains the term' do
      result = Widget.search('Widget')
      expect(result.to_a.size).to be_positive
      expect(result.to_a).to all(be_a(Widget))
    end

    it 'returns an empty result for unknown terms' do
      result = Widget.search('zzzzznonexistent')
      expect(result.to_a).to eq([])
    end
  end
end
