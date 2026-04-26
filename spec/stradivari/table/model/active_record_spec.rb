require 'spec_helper'

RSpec.describe Stradivari::Table::Model::ActiveRecord do
  describe '.sortable_by?' do
    it 'returns true for actual columns' do
      expect(Widget.sortable_by?('price')).to be_truthy
    end

    it 'returns true for declared stradivari sort scopes' do
      # name has both a column and a sort_by_name_asc scope; price has neither sort scope but is a column
      expect(Widget.sortable_by?('name')).to be_truthy
    end

    it 'returns true for keys matching a reflection name' do
      expect(Widget.sortable_by?('category_id')).to be_truthy
    end

    it 'returns false for unknown keys' do
      expect(Widget.sortable_by?('evil_injection')).to be_falsey
    end
  end
end

RSpec.describe Stradivari::Table::Model::Base do
  it 'recognises stradivari_scopes registered for sorting' do
    klass = Class.new do
      include Stradivari::Table::Model::Base
      def self.stradivari_scopes
        { custom_sort: { type: :string } }
      end
    end
    expect(klass.sortable_by?(:custom_sort)).to be_truthy
    expect(klass.sortable_by?(:other)).to be_falsey
  end
end
