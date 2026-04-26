# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stradivari::Railtie do
  it 'is a Rails engine' do
    expect(described_class.ancestors).to include(Rails::Engine)
  end

  describe 'initializers' do
    it 'mixes Filter::Model::ActiveRecord into ActiveRecord::Base' do
      expect(ActiveRecord::Base.singleton_class.ancestors).to include(Stradivari::Filter::Model::ActiveRecord::ClassMethods)
    end

    it 'mixes Table::Model::ActiveRecord into ActiveRecord::Base' do
      expect(ActiveRecord::Base.singleton_class.ancestors).to include(Stradivari::Table::Model::ActiveRecord::ClassMethods)
    end

    it 'includes StradivariHelper into ActionController::Base helpers' do
      expect(ActionController::Base.helpers).to respond_to(:table_for)
      expect(ActionController::Base.helpers).to respond_to(:filter_for)
    end

    it 'registers the xlsx mime type' do
      expect(Mime::Type.lookup_by_extension(:xlsx)).not_to be_nil
      expect(Mime[:xlsx].to_s).to eq('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    end
  end
end
