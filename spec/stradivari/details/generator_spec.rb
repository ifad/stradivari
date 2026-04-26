require 'spec_helper'

RSpec.describe Stradivari::Details::Generator do
  let(:view) { view_context }

  it 'renders a dl with dt/dt pairs for declared fields' do
    widget = create_widget(name: 'Acme', price: 42)
    out = view.details_for(widget) do
      field :name
      field :price
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.at_css('dl.dl-horizontal')).not_to be_nil
    labels = doc.css('dt').map(&:text)
    expect(labels).to include('Name', 'Price')
  end

  it 'omits fields with blank content (default behavior)' do
    widget = create_widget(description: nil)
    out = view.details_for(widget) do
      field :description
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.at_css('dt')).to be_nil
  end

  it 'includes blank fields when present: true is set' do
    widget = create_widget(description: nil)
    out = view.details_for(widget) do
      field :description, present: true
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.at_css('dt')&.text).to eq('Description')
  end

  it 'invokes a custom renderer block' do
    widget = create_widget(name: 'X')
    out = view.details_for(widget) do
      field :badge do |w|
        haml_tag :strong, "[#{w.name}]"
      end
    end
    expect(out).to include('[X]')
  end

  it 'honours the :if option' do
    widget = create_widget(name: 'X')
    out = view.details_for(widget) do
      field :name, if: -> { false }
    end
    doc = Nokogiri::HTML.fragment(out)
    expect(doc.at_css('dt')).to be_nil
  end
end
