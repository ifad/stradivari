# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stradivari::Filter::Generator do
  let(:view) { view_context }

  it 'renders the form wrapper, sort/direction hidden inputs and a Stradivari panel' do
    out = view.filter_for(Widget) do
      search :name_like
    end
    doc = Nokogiri::HTML.fragment(out)
    form = doc.at_css('form#filter-form')
    expect(form).not_to be_nil
    expect(form['data-stradivari-filter-context']).to eq('context')
    expect(form['data-stradivari-filter-namespace']).to eq('q')
    expect(doc.at_css('input[type="hidden"][name="sort"]')).not_to be_nil
    expect(doc.at_css('input[type="hidden"][name="direction"]')).not_to be_nil
    expect(doc.at_css('.stradivari-filter__panel')).not_to be_nil
    expect(out).not_to include('panel panel-info')
  end

  it 'omits the panel when inline: true' do
    out = view.filter_for(Widget, inline: true) do
      search :name_like
    end
    expect(out).not_to include('stradivari-filter__panel')
  end

  it 'detached forms drop hidden sort/direction and add data-detached' do
    out = view.filter_for(Widget, detached: true) do
      search :name_like
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.at_css('form[data-detached="true"]')).not_to be_nil
    expect(doc.at_css('form[data-stradivari-filter-context]')).to be_nil
    expect(doc.at_css('form[data-stradivari-filter-namespace]')).to be_nil
    expect(doc.at_css('form input[name="sort"]')).to be_nil
  end

  it 'renders selection, boolean, number, search, and date_range fields' do
    out = view.filter_for(Widget) do
      selection :kind, collection: Widget::KINDS.dup
      boolean :active
      number :priced_above
      search :name_like
      date_range :released_on
    end
    expect(out).to include('priced_above')
    expect(out).to include('name_like')
    expect(out).to include('active')
    expect(out).to include('kind')
  end

  it 'renders custom fields with a user-supplied renderer' do
    out = view.filter_for(Widget) do
      custom :my_thing, active: -> { true } do |attr, _opts|
        content_tag :div, "custom:#{attr}", class: 'my-thing'
      end
    end
    doc = Nokogiri::HTML.fragment(out)
    el = doc.at_css('div.my-thing')
    expect(el).not_to be_nil
    expect(el.text).to eq('custom:my_thing')
  end

  it 'raises when a renderer is given but :active option is missing' do
    expect do
      view.filter_for(Widget) do
        custom :foo do |attr, _opts|
          content_tag :div, attr
        end
      end
    end.to raise_error(ArgumentError, /active attribute block/)
  end

  it 'supports prepend and append blocks' do
    out = view.filter_for(Widget) do
      prepend(class: 'pre') { content_tag :div, 'PRE' }
      append(class: 'post') { content_tag :div, 'POST' }
      search :name_like
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.at_css('div.pre').text).to include('PRE')
    expect(doc.at_css('div.post').text).to include('POST')
  end
end

RSpec.describe Stradivari::Filter::Builder do
  describe '.value' do
    it 'returns the direct param when present' do
      expect(described_class.value({ 'name' => 'foo' }, 'name')).to eq('foo')
    end

    it 'falls back to <name>_eq for ransack predicates' do
      expect(described_class.value({ 'name_eq' => 'foo' }, 'name')).to eq('foo')
    end
  end

  describe '.active?' do
    it 'returns true when value is present' do
      expect(described_class).to be_active({ 'name' => 'x' }, 'name')
    end

    it 'returns false when value is blank' do
      expect(described_class).not_to be_active({ 'name' => '' }, 'name')
    end
  end

  describe '.priority and .prepare_classes' do
    it 'defaults priority to :normal' do
      expect(described_class.priority({})).to eq(:normal)
    end

    it 'returns the requested priority' do
      expect(described_class.priority(priority: :high)).to eq(:high)
    end

    it 'adds priority class and closes low-priority inactive fields' do
      expect(described_class.prepare_classes(priority: :low, active_field: false)).to include('stradivari-filter__control--priority-low')
      expect(described_class.prepare_classes(priority: :low, active_field: false)).to include('stradivari-filter__control--closed')
      expect(described_class.prepare_classes(priority: :low, active_field: true)).not_to include('stradivari-filter__control--closed')
    end
  end
end
