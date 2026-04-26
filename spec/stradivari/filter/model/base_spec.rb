# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stradivari::Filter::Model::Base do
  let(:host) do
    Class.new do
      include Stradivari::Filter::Model::Base

      def self.name = 'DummyHost'
    end
  end

  describe '.stradivari_scope' do
    it 'raises when given both a block parameter and a yielded block' do
      param_block = ->(_) { :ok }
      expect do
        host.stradivari_scope(:foo, param_block) { |_| :nope }
      end.to raise_error(Stradivari::Error, /both via parameter and syntax/)
    end

    it 'records the scope when called with a block' do
      host.singleton_class.define_method(:scope) { |_n, _c| } # stub AR.scope
      host.stradivari_scope(:foo, type: :string) { |_v| :ok }
      expect(host.stradivari_scopes).to include(:foo)
      expect(host.stradivari_scopes[:foo][:type]).to eq(:string)
    end
  end

  describe 'deprecated APIs' do
    it 'forwards configure_scope_search to stradivari_filter_options' do
      host.singleton_class.define_method(:stradivari_filter_options) { |*a| [:configured, *a] }
      result = silence_stderr { host.configure_scope_search(:foo) }
      expect(result).to eq(%i[configured foo])
    end

    it 'forwards scope_search to stradivari_scope' do
      seen = nil
      host.singleton_class.define_method(:stradivari_scope) do |*a, &b|
        seen = [a, b]
        :ok
      end
      silence_stderr { host.scope_search(:bar, type: :number) { :hi } }
      expect(seen[0]).to eq([:bar, { type: :number }])
      expect(seen[1].call).to eq(:hi)
    end

    it 'forwards extended_search to stradivari_filter' do
      host.singleton_class.define_method(:stradivari_filter) { |*a| [:filtered, *a] }
      result = silence_stderr { host.extended_search(:x) }
      expect(result).to eq(%i[filtered x])
    end
  end

  describe 'unimplemented methods' do
    it 'stradivari_filter raises NotImplementedError' do
      expect { host.stradivari_filter({}) }.to raise_error(NotImplementedError)
    end

    it 'stradivari_type raises NotImplementedError' do
      expect { host.stradivari_type(:foo) }.to raise_error(NotImplementedError)
    end
  end

  def silence_stderr
    orig = $stderr
    $stderr = StringIO.new
    yield
  ensure
    $stderr = orig
  end
end
