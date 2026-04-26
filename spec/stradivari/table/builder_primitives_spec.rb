# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Stradivari::Table::Builder primitive lambdas' do
  let(:view) { view_context }

  describe Stradivari::Table::Builder::CheckboxBuilder do
    it 'returns an empty string from its render lambda' do
      result = view.instance_exec(:obj, :attr, {}, &described_class.render)
      expect(result).to eq('')
    end
  end

  describe Stradivari::Table::Builder::DateBuilder do
    let(:obj) { Struct.new(:released_on).new(Date.new(2024, 1, 15)) }

    it 'formats with strftime when :format is given' do
      result = view.instance_exec(obj, :released_on, { format: '%Y/%m/%d' }, &described_class.render)
      expect(result).to eq('2024/01/15')
    end

    it 'falls back to I18n.l when no format is given' do
      result = view.instance_exec(obj, :released_on, {}, &described_class.render)
      expect(result).to eq(I18n.l(Date.new(2024, 1, 15)))
    end

    it 'returns nil when the attribute is blank' do
      blank = Struct.new(:released_on).new(nil)
      result = view.instance_exec(blank, :released_on, {}, &described_class.render)
      expect(result).to be_nil
    end
  end

  describe Stradivari::Table::Builder::TextLinkBuilder do
    it 'returns nil when attribute is blank' do
      obj = Struct.new(:name).new(nil)
      view = Object.new
      result = view.instance_exec(obj, :name, {}, &described_class.render)
      expect(result).to be_nil
    end
  end
end
