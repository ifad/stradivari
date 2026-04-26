# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CSV/XLSX child rendering and counters' do
  let(:view) { view_context }

  it 'CSV generator emits a row per child via child_method' do
    parent = create_widget(name: 'P')
    child = create_widget(name: 'C')
    parent.singleton_class.define_method(:sub_widgets) { [child] }
    csv = view.csv_for([parent], child_method: :sub_widgets) do
      column :name
    end
    parsed = CSV.parse(csv)
    expect(parsed.map(&:first)).to include('P', 'C')
  end

  it 'XLSX generator emits a row per child via child_method' do
    parent = create_widget(name: 'P')
    child = create_widget(name: 'C')
    parent.singleton_class.define_method(:sub_widgets) { [child] }
    binary = view.xlsx_for([parent], child_method: :sub_widgets) do
      column :name
    end
    open_xlsx(binary) do |sheet|
      values = (1..sheet.last_row).map { |r| sheet.row(r).first }
      expect(values).to include('P', 'C')
    end
  end

  it 'XLSX generator applies per-column :style without raising' do
    create_widget(name: 'X')
    binary = view.xlsx_for(Widget.all) do
      column :name, style: { sz: 12 }
    end
    open_xlsx(binary) do |sheet|
      expect(sheet.row(2).first).to eq('X')
    end
  end

  it 'XLSX column with type: option uses public_send rather than the builder' do
    create_widget(name: 'X', released_on: Date.new(2024, 1, 1))
    binary = view.xlsx_for(Widget.all) do
      column :released_on, type: :date
    end
    open_xlsx(binary) do |sheet|
      # Excel stores dates as numeric serials. Just confirm cell is a positive number.
      expect(sheet.row(2).first.to_f).to be_positive
    end
  end

  it 'XLSX column with a renderer block invokes it' do
    create_widget(name: 'lower')
    binary = view.xlsx_for(Widget.all) do
      column :name do |w|
        concat w.name.upcase
      end
    end
    open_xlsx(binary) do |sheet|
      expect(sheet.row(2).first).to eq('LOWER')
    end
  end
end

RSpec.describe 'Table::Generator paginated counters' do
  let(:view) { view_context }

  let(:fake_paginated_class) do
    Class.new do
      attr_reader :records

      def initialize(records, current_page:, per_page:, total_count:)
        @records = records
        @current_page = current_page
        @per_page = per_page
        @total_count = total_count
      end

      def each(&block) = @records.each(&block)
      def empty? = @records.empty?
      def present? = !empty?
      def map(&block) = @records.map(&block)
      def first = @records.first
      def klass = @records.first.class

      attr_reader :current_page

      def total_pages = (@total_count.to_f / @per_page).ceil
      def num_pages = total_pages
      def limit_value = @per_page
      attr_reader :total_count
    end
  end

  it 'renders "1 to N out of T" on the first page' do
    create_widgets(3)
    page = fake_paginated_class.new(Widget.all.to_a, current_page: 1, per_page: 2, total_count: 5)
    out = view.table_for(page) { column :name }
    expect(out).to include('1 to 2 out of 5 records displayed')
  end

  it 'renders the last-page counter using total_count' do
    create_widgets(3)
    page = fake_paginated_class.new(Widget.all.to_a, current_page: 3, per_page: 2, total_count: 5)
    out = view.table_for(page) { column :name }
    expect(out).to include('5 to 5 out of 5 records displayed')
  end

  it 'renders an interior page counter' do
    create_widgets(3)
    page = fake_paginated_class.new(Widget.all.to_a, current_page: 2, per_page: 2, total_count: 6)
    out = view.table_for(page) { column :name }
    expect(out).to include('3 to 4 out of 6 records displayed')
  end

  it 'falls back to total_pages when num_pages is missing' do
    klass = Class.new(fake_paginated_class) do
      undef_method :num_pages
    end
    create_widgets(2)
    page = klass.new(Widget.all.to_a, current_page: 1, per_page: 1, total_count: 2)
    out = view.table_for(page) { column :name }
    expect(out).to include('records displayed')
  end
end

RSpec.describe 'Table::Generator download text' do
  let(:view) do
    v = view_context
    # Provide a fake request env so view.url_for(params.merge(format: ...)) resolves.
    v.controller.request.path_info = '/widgets'
    v.controller.params = ActionController::Parameters.new(controller: 'widgets', action: 'index')
    v
  end

  before { create_widget }

  it 'shows "Export to CSV..." when downloadable: :csv' do
    out = view.table_for(Widget.all, downloadable: :csv) do
      column :name
    end
    expect(out).to include('Export to CSV...')
  end

  it 'shows "Export..." when downloadable: true (default csv)' do
    out = view.table_for(Widget.all, downloadable: true) do
      column :name
    end
    expect(out).to include('Export to CSV...')
  end

  it 'shows the event download data hook when downloadable_type: :event' do
    out = view.table_for(Widget.all, downloadable: :csv, downloadable_type: :event) do
      column :name
    end
    expect(out).to include('data-stradivari-table-download="event"')
    expect(out).not_to include('downloadable_event')
  end
end
