require 'spec_helper'

RSpec.describe Stradivari::Concerns::TableBuilder do
  let(:host_class) do
    Class.new do
      include Stradivari::Concerns::TableBuilder
      attr_writer :opts, :type
      def initialize(opts: {}, type: nil)
        @opts = opts
        @type = type
      end
      attr_reader :type
    end
  end

  def builder_for(type: nil, opts: {})
    host_class.new(type: type, opts: opts).builder
  end

  it 'maps integer columns to NumberBuilder' do
    expect(builder_for(type: :integer)).to eq(Stradivari::Table::Builder::NumberBuilder)
  end

  it 'maps date columns to DateBuilder' do
    expect(builder_for(type: :date)).to eq(Stradivari::Table::Builder::DateBuilder)
  end

  it 'maps datetime columns to DateBuilder' do
    expect(builder_for(type: :datetime)).to eq(Stradivari::Table::Builder::DateBuilder)
  end

  it 'maps boolean columns to BooleanBuilder' do
    expect(builder_for(type: :boolean)).to eq(Stradivari::Table::Builder::BooleanBuilder)
  end

  it 'falls back to TextBuilder for string and unknown types' do
    expect(builder_for(type: :string)).to eq(Stradivari::Table::Builder::TextBuilder)
    expect(builder_for(type: nil)).to eq(Stradivari::Table::Builder::TextBuilder)
  end

  it 'honours an explicit :builder option' do
    custom = Class.new
    expect(builder_for(opts: { builder: custom })).to eq(custom)
  end
end
