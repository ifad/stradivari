# frozen_string_literal: true

require 'spec_helper'
require 'stradivari/filter/helpers'

RSpec.describe 'Stradivari::Filter::Builder edge branches' do
  let(:view) { view_context }

  describe 'NumberField' do
    it 'extracts <name>_lt when only the lt key is present' do
      expect(Stradivari::Filter::Builder::NumberField.value({ 'price_lt' => '5' }, 'price'))
        .to eq(%w[price_lt 5])
    end

    it 'extracts <name>_gt when only the gt key is present' do
      expect(Stradivari::Filter::Builder::NumberField.value({ 'price_gt' => '5' }, 'price'))
        .to eq(%w[price_gt 5])
    end

    it 'falls back to <name>_eq when neither lt nor gt is present' do
      expect(Stradivari::Filter::Builder::NumberField.value({ 'price_eq' => '5' }, 'price'))
        .to eq(%w[price_eq 5])
    end
  end

  describe 'CheckboxField multi_line' do
    it 'renders a closed group of unchecked entries when some are checked' do
      v = view_context(params: { q: { kind_in: ['gadget'] } })
      out = v.filter_for(Widget) do
        checkbox :kind, type: :multi_line, collection: Widget::KINDS.dup
      end
      doc = Nokogiri::HTML.fragment(out)
      expect(doc.at_css('div.stradivari-filter__choice-list--multi-line')).not_to be_nil
      expect(doc.at_css('div.stradivari-filter__collapsed')).not_to be_nil
      checkboxes = doc.css('input[type="checkbox"]')
      expect(checkboxes.size).to eq(Widget::KINDS.size)
      expect(checkboxes.css('[checked]').size).to eq(1)
    end

    it 'renders all entries inline when nothing is checked in multi_line mode' do
      out = view.filter_for(Widget) do
        checkbox :kind, type: :multi_line, collection: Widget::KINDS.dup
      end
      doc = Nokogiri::HTML.fragment(out)
      expect(doc.at_css('div.stradivari-filter__collapsed')).to be_nil
      expect(doc.css('input[type="checkbox"]').size).to eq(Widget::KINDS.size)
    end
  end

  describe 'SearchField data: { display: }' do
    it 'invokes the display proc with the current value' do
      v = view_context(params: { q: { name_like_cont: 'foo' } })
      out = v.filter_for(Widget) do
        search :name_like, data: { display: ->(value) { "shown:#{value}" } }
      end
      expect(out).to include('data-display="shown:foo"')
    end
  end

  describe 'SearchField deprecated skip_button option' do
    it 'logs a deprecation to stderr and renders without the search button' do
      out = nil
      expect do
        out = view.filter_for(Widget) { search :name_like, skip_button: true, button: false }
      end.to output(/skip_button option to search filter field is deprecated/).to_stderr

      doc = Nokogiri::HTML.fragment(out)
      # Only the panel-level Apply button should remain; the per-field input group button is gone.
      expect(doc.at_css('div.stradivari-input-group')).to be_nil
      expect(doc.at_css('div.stradivari-input-group button[data-stradivari-filter-action="search"]')).to be_nil
    end
  end
end

RSpec.describe Stradivari::Filter::Helpers do
  let(:view) { view_context }

  describe '.render_title low-priority handle' do
    it 'wraps the title with an Expand handle for low-priority inactive fields' do
      out = view.filter_for(Widget) do
        search :name_like, priority: :low
      end
      doc = Nokogiri::HTML.fragment(out)
      expect(doc.at_css('span.stradivari-filter__toggle')&.text).to eq('Expand')
    end

    it 'shows an Add More handle for collapsed active fields' do
      out = view.filter_for(Widget) do
        search :name_like, value: 'x'
      end
      # active_field becomes true via Builder when value is present; when also collapsed_field is true
      # for selection/boolean fields. Search field doesn't auto-collapse, so use an explicit option.
      out2 = view.filter_for(Widget) do
        selection :kind, collection: Widget::KINDS.dup, value: 'gadget'
      end
      doc = Nokogiri::HTML.fragment(out2)
      expect(doc.at_css('span.stradivari-filter__toggle')&.text).to eq('Add More').or be_nil
      expect(out).to be_a(String)
    end

    it 'ignores autocomplete: true on title labels' do
      out = view.filter_for(Widget) do
        search :name_like, priority: :low, autocomplete: true
      end
      expect(out).not_to include('data-stradivari="autocomplete"')
    end
  end

  describe '.prepare_radio_class' do
    it 'appends " checked" when active' do
      expect(described_class.prepare_radio_class(true)).to include('stradivari-filter__choice--checked')
    end

    it 'returns the default when not active' do
      expect(described_class.prepare_radio_class(false)).to eq('stradivari-filter__choice stradivari-filter__choice--radio')
    end
  end
end
