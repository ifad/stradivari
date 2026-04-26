# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Stradivari::Table::Builder integrations' do
  before { create_widgets(2) }

  let(:view) { view_context }

  it 'renders a date column without raising' do
    out = view.table_for(Widget.all) do
      column :released_on, type: :date
    end
    expect(out).to include('<table')
  end

  it 'renders a boolean column with Yes/No' do
    out = view.table_for(Widget.all) do
      column :active, type: :boolean
    end
    expect(out).to match(/Yes|No/)
  end

  it 'renders a number column' do
    out = view.table_for(Widget.all) do
      column :price, type: :integer
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.css('tbody td').first.text.strip).to match(/\d+/)
  end
end

RSpec.describe Stradivari::Table::Builder::ActionBuilder do
  it 'returns a lambda' do
    expect(described_class.render).to be_a(Proc)
  end
end

RSpec.describe Stradivari::Table::Builder::TextLinkBuilder do
  it 'returns a lambda' do
    expect(described_class.render).to be_a(Proc)
  end

  it 'returns nil when the attribute is blank' do
    obj = Struct.new(:name).new(nil)
    view = Object.new
    result = view.instance_exec(obj, :name, {}, &described_class.render)
    expect(result).to be_nil
  end
end

RSpec.describe Stradivari::Table::Builder::CheckboxBuilder do
  it 'returns a lambda' do
    expect(described_class.render).to be_a(Proc)
  end
end
