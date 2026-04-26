require 'spec_helper'

RSpec.describe Stradivari::Concerns::CssFriendly do
  let(:host) do
    Class.new do
      include Stradivari::Concerns::CssFriendly
    end.new
  end

  it 'replaces brackets with underscores' do
    expect(host.css_friendly('foo[bar]')).to eq('foo_bar_')
  end

  it 'replaces dots, commas and colons with underscores' do
    expect(host.css_friendly('foo.bar,baz:qux')).to eq('foo_bar_baz_qux')
  end

  it 'leaves friendly identifiers untouched' do
    expect(host.css_friendly('plain_id-1')).to eq('plain_id-1')
  end
end
