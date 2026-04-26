require 'spec_helper'

RSpec.describe Stradivari::Generator do
  let(:view) { view_context }

  it 'is abstract: subclasses must implement #to_s and #klass' do
    base = described_class.new(view, nil)
    expect { base.to_s }.to raise_error(NotImplementedError)
    expect { base.klass }.to raise_error(NotImplementedError)
  end

  it 'extracts options from the trailing hash and exposes data and view' do
    gen = described_class.new(view, [1, 2, 3], class: 'foo')
    expect(gen.view).to eq(view)
    expect(gen.data).to eq([1, 2, 3])
    expect(gen.opts).to eq(class: 'foo')
  end

  it 'delegates haml helpers to the view' do
    expect(described_class.new(view, nil).respond_to?(:capture_haml)).to be_truthy
  end

  describe Stradivari::Generator::Tag do
    let(:parent_double) do
      Class.new do
        def view; @view; end
        def klass; Widget; end
        attr_writer :view
      end.new.tap { |p| p.view = view_context }
    end

    it 'is enabled by default' do
      tag = described_class.new(parent_double, {})
      expect(tag.enabled?).to be_truthy
    end

    it 'disables when :if returns false' do
      tag = described_class.new(parent_double, if: -> { false })
      expect(tag.enabled?).to be_falsey
    end

    it 'disables when :unless returns true' do
      tag = described_class.new(parent_double, unless: -> { true })
      expect(tag.enabled?).to be_falsey
    end

    it 'returns the supplied :title verbatim when a string' do
      tag = described_class.new(parent_double, title: 'Hello')
      expect(tag.title).to eq('Hello')
    end

    it 'returns an empty string when :title is false' do
      tag = described_class.new(parent_double, title: false)
      expect(tag.title).to eq('')
    end

    it 'falls back to humanized name when :title is nil and host has no human_attribute_name' do
      no_attr_class = Class.new
      parent = parent_double
      parent.singleton_class.define_method(:klass) { no_attr_class }
      tag = described_class.new(parent, {})
      tag.singleton_class.define_method(:name) { :wibble_thing }
      expect(tag.title).to eq('Wibble Things'.sub('s', '')) # tolerant: depends on titleize/pluralization
    end
  end
end
