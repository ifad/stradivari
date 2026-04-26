require 'spec_helper'

RSpec.describe StradivariHelper do
  let(:view) { view_context }

  describe '#search_param' do
    it 'returns the value of params[:q][name] when present' do
      v = view_context(params: { q: { name: 'Acme' } })
      expect(v.search_param(:name)).to eq('Acme')
    end

    it 'returns nil for blank values' do
      v = view_context(params: { q: { name: '' } })
      expect(v.search_param(:name)).to be_nil
    end

    it 'returns nil when the namespace key is missing' do
      v = view_context(params: {})
      expect(v.search_param(:name)).to be_nil
    end
  end

  describe '#select_tree_check_box' do
    it 'accepts a single options hash' do
      out = view.select_tree_check_box(name: 'tag1')
      expect(out).to include('data-bind="select-tree"')
      expect(out).to include('data-select-tree-name="tag1"')
      expect(out).to include('id="tag1"')
    end

    it 'accepts (name, value, checked, options) variant' do
      out = view.select_tree_check_box('parent_tag', '5', true, name: 'child', parent: 'parent_tag')
      expect(out).to include('checked')
      expect(out).to include('data-select-tree-parent="parent_tag"')
    end

    it 'raises ArgumentError on a wrong arity' do
      expect { view.select_tree_check_box(:a, :b) }.to raise_error(ArgumentError, /Wrong number of arguments/)
    end

    it 'propagates count_total when provided' do
      out = view.select_tree_check_box(name: 'thing', count_total: 42)
      expect(out).to include('data-select-tree-count-total="42"')
    end
  end

  describe 'top-level *_for helpers' do
    it 'returns a string from each helper' do
      create_widget
      expect(view.table_for(Widget.all) { column :id }).to be_a(String)
      expect(view.csv_for(Widget.all) { column :id }).to be_a(String)
      expect(view.xlsx_for(Widget.all) { column :id }).to be_a(String)
      expect(view.details_for(Widget.first) { field :id }).to be_a(String)
      expect(view.filter_for(Widget) { search :name_like }).to be_a(String)
      expect(view.tabs_for([1]) { tab 'A', 'a', [1] do |_|; haml_concat 'x'; end }).to be_a(String)
    end
  end
end
