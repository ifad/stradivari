require 'spec_helper'

RSpec.describe Stradivari::Generator::Tag, '#title' do
  let(:view) { view_context }

  let(:parent) do
    Struct.new(:view, :klass).new(view, Widget)
  end

  it 'evaluates a Proc :title against the view' do
    tag = described_class.new(parent, title: proc { 'from-proc' })
    expect(tag.title).to eq('from-proc')
  end

  it 'returns "" when :title is false' do
    tag = described_class.new(parent, title: false)
    expect(tag.title).to eq('')
  end

  it 'returns the literal :title when given a string' do
    tag = described_class.new(parent, title: 'Literal')
    expect(tag.title).to eq('Literal')
  end

  it 'falls back to klass.human_attribute_name when :title is nil' do
    tag = described_class.new(parent, {})
    tag.singleton_class.define_method(:name) { :name }
    expect(tag.title).to eq(Widget.human_attribute_name(:name))
  end

  it 'titleizes the name when klass does not respond to human_attribute_name' do
    no_attr_klass = Class.new
    p = Struct.new(:view, :klass).new(view, no_attr_klass)
    tag = described_class.new(p, {})
    tag.singleton_class.define_method(:name) { :wibble_thing }
    expect(tag.title).to eq('Wibble Thing')
  end
end
