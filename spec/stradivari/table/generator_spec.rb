# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stradivari::Table::Generator do
  describe 'no-data rendering' do
    it 'renders the default no-data message when collection is empty' do
      view = view_context
      out = view.table_for([]) do
        column :id
      end
      doc = Nokogiri::HTML.fragment(out)
      expect(doc.at_css('div.stradivari-table__empty')).not_to be_nil
      expect(doc.at_css('table')).to be_nil
      expect(out).not_to include('alert-warning')
    end

    it 'renders a custom no_data block when provided' do
      view = view_context
      out = view.table_for([]) do
        no_data do
          content_tag :strong, 'No widgets at all'
        end
        column :id
      end
      expect(out).to include('No widgets at all')
    end
  end

  describe 'visibility toggles' do
    before { create_widgets(2) }

    it 'omits the thead when header_visible: false' do
      view = view_context
      out = view.table_for(Widget.all, header_visible: false) do
        column :name
      end
      doc = Nokogiri::HTML.fragment(out)
      expect(doc.at_css('thead')).to be_nil
      expect(doc.at_css('tbody')).not_to be_nil
    end

    it 'omits the tfoot when footer_visible: false' do
      view = view_context
      out = view.table_for(Widget.all, footer_visible: false) do
        column :name
      end
      expect(out).not_to include('<tfoot')
    end
  end

  describe 'columns helper' do
    it 'declares multiple columns at once' do
      create_widgets(1)
      view = view_context
      out = view.table_for(Widget.all) do
        columns :id, :name, :price
      end
      doc = Nokogiri::HTML.fragment(out)
      expect(doc.css('thead th').size).to eq(3)
    end
  end

  describe 'custom column renderers' do
    it 'invokes the renderer block per row' do
      create_widgets(1)
      view = view_context
      out = view.table_for(Widget.all) do
        column :name do |w|
          content_tag :strong, "BANG-#{w.name}"
        end
      end
      expect(out).to include('BANG-Widget 0')
    end
  end

  describe 'klass detection' do
    it 'falls back to first element class when data does not respond to :klass' do
      create_widgets(1)
      gen = described_class.new(view_context, Widget.all.to_a) do
        column :id
      end
      expect(gen.klass).to eq(Widget)
    end
  end

  describe 'custom footer' do
    it 'renders a footer block when declared' do
      create_widgets(1)
      view = view_context
      out = view.table_for(Widget.all) do
        column :name
        footer(class: 'totals') do
          content_tag :strong, 'TOTAL'
        end
      end
      expect(out).to include('TOTAL')
      expect(out).to include('totals')
    end
  end

  describe 'parent/child rows' do
    it 'walks children when child_method option is set' do
      parent = create_widget(name: 'P')
      child  = create_widget(name: 'C')
      parent.singleton_class.define_method(:sub_widgets) { [child] }
      view = view_context
      out = view.table_for([parent], child_method: :sub_widgets) do
        column :name
      end
      doc = Nokogiri::HTML.fragment(out)
      names = doc.css('tbody td').map { |td| td.text.strip }
      expect(names).to include('P', 'C')
    end
  end
end
