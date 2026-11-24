# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Stradivari::Filter::Builder field branches' do
  let(:view) { view_context }

  it 'search field can render with a button (:button option)' do
    out = view.filter_for(Widget) do
      search :name_like, button: true
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.at_css('div.stradivari-input-group')).not_to be_nil
    expect(doc.at_css('button[data-stradivari-filter-action="search"]')).not_to be_nil
    expect(out).not_to include('class="input-group"')
  end

  it 'search field accepts data: { remote_url: } and sets data-remote-url' do
    out = view.filter_for(Widget) do
      search :name_like, data: { remote_url: '/auto' }
    end
    expect(out).to include('data-remote-url="/auto"')
  end

  it 'ignores autocomplete: true on search fields' do
    out = view.filter_for(Widget) do
      search :name_like, autocomplete: true
    end
    expect(out).not_to include('data-stradivari="autocomplete"')
  end

  it 'search field accepts a sort: option and sets data-sort' do
    out = view.filter_for(Widget) do
      search :name_like, sort: 'name'
    end
    expect(out).to include('data-sort="name"')
  end

  it 'date_range field renders two date inputs' do
    out = view.filter_for(Widget) do
      date_range :released_on
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.css('input').size).to be >= 2
  end

  it 'checkbox field renders a checkbox per collection entry' do
    out = view.filter_for(Widget) do
      checkbox :kind, collection: Widget::KINDS.dup
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.css('input[type="checkbox"]').size).to eq(Widget::KINDS.size)
  end

  it 'boolean field renders a checkbox by default' do
    out = view.filter_for(Widget) do
      boolean :active
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.at_css('input[type="checkbox"]')).not_to be_nil
    expect(doc.at_css('.stradivari-filter__choice-text')&.text).to eq('Active')
  end

  it 'boolean field renders Yes/No radios when tristate: true' do
    out = view.filter_for(Widget) do
      boolean :active, tristate: true
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.css('input[type="radio"]').size).to be >= 2
    expect(doc.css('.stradivari-filter__choice-text').map(&:text)).to include('Yes', 'No')
  end

  it 'selection field renders radios when collection size <= radios_count' do
    out = view.filter_for(Widget) do
      selection :kind, collection: Widget::KINDS.dup
    end
    doc = Nokogiri::HTML.fragment(out)
    # one radio per kind plus a final "Any" blank radio (include_blank default).
    expect(doc.css('input[type="radio"]').size).to eq(Widget::KINDS.size + 1)
    expect(doc.css('input[type="radio"][checked]').size).to eq(1)
    expect(doc.css('input[type="radio"]').map { |input| input['value'] }).to include(*Widget::KINDS, '')
    expect(doc.css('.stradivari-filter__choice-text').map(&:text)).to include('Any')
  end

  it 'selection field renders a select when collection size > radios_count' do
    out = view.filter_for(Widget) do
      selection :kind, collection: %w[a b c d e f g h]
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.at_css('select.stradivari-control')).not_to be_nil
    expect(out).not_to include('form-control')
    expect(doc.css('option').size).to be >= 8
  end

  it 'selection field renders a multiple select with the extra class, without a blank option' do
    out = view.filter_for(Widget) do
      selection :category_id, collection: [%w[One 1], %w[Two 2]], multiple: true, include_blank: false, class: 'js-select2'
    end
    doc = Nokogiri::HTML.fragment(out)
    select = doc.at_css('select.stradivari-control.js-select2')
    expect(select['multiple']).to eq('multiple')
    expect(select['name']).to eq('q[category_id_in][]')
    expect(select.css('option').pluck('value')).to eq(%w[1 2])
  end

  it 'selection field adds the form group class to its wrapper' do
    out = view.filter_for(Widget) do
      selection :kind, collection: Widget::KINDS.dup, form_group_class: 'inline-choices'
    end
    expect(Nokogiri::HTML.fragment(out).at_css('.stradivari-filter__field.inline-choices')).not_to be_nil
  end

  it 'reads the selected values of a multiple selection from the _in parameter' do
    expect(Stradivari::Filter::Builder.value({ 'kind_in' => %w[a b] }, 'kind')).to eq(%w[a b])
  end

  it 'closes every inactive low-priority control with the modifier the stylesheet hides' do
    out = view.filter_for(Widget) do
      search :name_like, priority: :low
      number :priced_above, priority: :low
      date_range :released_on, priority: :low
      checkbox :kind_chk, collection: Widget::KINDS.dup, priority: :low
      selection :kind, collection: Widget::KINDS.dup, priority: :low
      boolean :active, tristate: true, priority: :low
    end
    fields = Nokogiri::HTML.fragment(out).css('[data-stradivari-filter-field-wrapper]')
    expect(fields.size).to eq(6)
    fields.each do |field|
      expect(field.css('[data-stradivari-filter-toggle]').size).to eq(1)
      expect(field.at_css('[data-stradivari-filter-collapsible]')&.classes).to include('stradivari-filter__control--closed')
    end
  end
end
