# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stradivari::CSV::Generator do
  let(:view) { view_context }

  it 'returns a parseable CSV with header row' do
    create_widgets(2)
    csv_string = view.csv_for(Widget.all) do
      column :id
      column :name
      column :price
    end
    parsed = CSV.parse(csv_string)
    expect(parsed.first).to eq(%w[Id Name Price])
    expect(parsed.size).to eq(3)
  end

  it 'invokes custom column renderers' do
    create_widget(name: 'Foo')
    csv_string = view.csv_for(Widget.all) do
      column :upper do |w|
        concat w.name.upcase
      end
    end
    parsed = CSV.parse(csv_string)
    expect(parsed.last.first).to eq('FOO')
  end

  it 'strips whitespace from rendered cells' do
    create_widget(name: '  Padded  ')
    csv_string = view.csv_for(Widget.all) do
      column :name
    end
    parsed = CSV.parse(csv_string)
    expect(parsed.last.first).to eq('Padded')
  end

  context 'with special characters' do
    let(:name) { %(Doe, John "JD" & Co's) }

    before { create_widget(name: name) }

    it 'writes attribute and block columns as raw text' do
      csv_string = view.csv_for(Widget.all) do
        column :name
        column(:returned, &:name)
        column(:concatenated) { |w| concat w.name }
      end
      expect(CSV.parse(csv_string).last).to eq([name, name, name])
    end

    it 'writes raw text when rendered from an ERB template' do
      csv_string = view.render(inline: <<~ERB)
        <%= csv_for(Widget.all) do %>
          <% column :name %>
          <% column :erb do |w| %><%= w.name %><% end %>
        <% end %>
      ERB
      expect(CSV.parse(csv_string.strip).last).to eq([name, name])
    end
  end
end
