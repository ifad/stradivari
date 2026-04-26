# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stradivari::Table::Model::ActiveRecord do
  describe '.sortable_by?' do
    it 'returns true for actual columns' do
      expect(Widget).to be_sortable_by('price')
    end

    it 'returns true for declared stradivari sort scopes' do
      # name has both a column and a sort_by_name_asc scope; price has neither sort scope but is a column
      expect(Widget).to be_sortable_by('name')
    end

    it 'returns true for keys matching a reflection name' do
      expect(Widget).to be_sortable_by('category_id')
    end

    it 'returns false for unknown keys' do
      expect(Widget).not_to be_sortable_by('evil_injection')
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
    expect(klass).to be_sortable_by(:custom_sort)
    expect(klass).not_to be_sortable_by(:other)
  end
end
