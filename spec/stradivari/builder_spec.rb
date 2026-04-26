# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stradivari::Builder do
  it 'raises NotImplementedError when .render is called on the base class' do
    expect { described_class.singleton_class.render }.to raise_error(NotImplementedError)
  end
end
