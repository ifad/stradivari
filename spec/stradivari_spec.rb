require 'spec_helper'

RSpec.describe Stradivari do
  it 'has a version number' do
    expect(Stradivari::VERSION).not_to be_nil
    expect(Stradivari::VERSION).to match(/\A\d+\.\d+\.\d+/)
  end

  it 'defines an Error class inheriting from StandardError' do
    expect(Stradivari::Error.new).to be_a(StandardError)
  end

  it 'autoloads its top-level modules' do
    expect(defined?(Stradivari::Builder)).to eq('constant')
    expect(defined?(Stradivari::Generator)).to eq('constant')
    expect(defined?(Stradivari::Controller)).to eq('constant')
    expect(defined?(Stradivari::Details)).to eq('constant')
    expect(defined?(Stradivari::Table)).to eq('constant')
    expect(defined?(Stradivari::Tabs)).to eq('constant')
    expect(defined?(Stradivari::Filter)).to eq('constant')
    expect(defined?(Stradivari::CSV)).to eq('constant')
    expect(defined?(Stradivari::XLSX)).to eq('constant')
  end

  it 'autoloads concerns' do
    expect(defined?(Stradivari::Concerns::TableBuilder)).to eq('constant')
    expect(defined?(Stradivari::Concerns::CssFriendly)).to eq('constant')
  end
end
