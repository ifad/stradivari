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

  it 'search field with autocomplete: true sets data-stradivari=autocomplete' do
    out = view.filter_for(Widget) do
      search :name_like, autocomplete: true
    end
    expect(out).to include('data-stradivari="autocomplete"')
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
  end

  it 'boolean field renders Yes/No radios when tristate: true' do
    out = view.filter_for(Widget) do
      boolean :active, tristate: true
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.css('input[type="radio"]').size).to be >= 2
  end

  it 'selection field renders radios when collection size <= radios_count' do
    out = view.filter_for(Widget) do
      selection :kind, collection: Widget::KINDS.dup
    end
    doc = Nokogiri::HTML.fragment(out)
    # one radio per kind plus a final "Any" blank radio (include_blank default).
    expect(doc.css('input[type="radio"]').size).to eq(Widget::KINDS.size + 1)
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
end
