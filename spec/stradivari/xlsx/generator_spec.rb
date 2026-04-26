require 'spec_helper'

RSpec.describe Stradivari::XLSX::Generator do
  let(:view) { view_context }

  it 'produces a valid XLSX file' do
    create_widgets(2)
    binary = view.xlsx_for(Widget.all) do
      column :id
      column :name
      column :price
    end
    open_xlsx(binary) do |sheet|
      expect(sheet.row(1)).to eq(['Id', 'Name', 'Price'])
      expect(sheet.last_row).to eq(3) # header + 2
    end
  end

  it 'renders a no-data sheet when collection is empty' do
    binary = view.xlsx_for(Widget.none) do
      column :id
    end
    open_xlsx(binary) do |sheet|
      expect(sheet.row(1).first).to eq('There is no data.')
    end
  end

  it 'uses the :sheet option as the worksheet name' do
    create_widget
    binary = view.xlsx_for(Widget.all, sheet: 'MySheet') do
      column :name
    end
    open_xlsx(binary) do |sheet|
      expect(sheet.sheets).to include('MySheet')
    end
  end
end

RSpec.describe Stradivari::XLSX::Controller, type: :request do
  before { create_widgets(1) }

  describe '#_stradivari_xlsx_file_name' do
    let(:dummy) do
      Class.new do
        include Stradivari::XLSX::Controller
      end.new
    end

    it 'defaults to "export.xlsx" when filename is nil' do
      expect(dummy.send(:_stradivari_xlsx_file_name, nil)).to eq('export.xlsx')
    end

    it 'defaults when filename is whitespace' do
      expect(dummy.send(:_stradivari_xlsx_file_name, "  \t")).to eq('export.xlsx')
    end

    it 'preserves a provided filename and adds .xlsx' do
      expect(dummy.send(:_stradivari_xlsx_file_name, 'report')).to eq('report.xlsx')
    end

    it 'normalises a provided filename already ending in .xlsx' do
      expect(dummy.send(:_stradivari_xlsx_file_name, 'report.xlsx')).to eq('report.xlsx')
    end

    it 'truncates names longer than 119 chars and appends -cut' do
      long = 'a' * 200
      result = dummy.send(:_stradivari_xlsx_file_name, long)
      expect(result.length).to be <= 128
      expect(result).to end_with('-cut.xlsx')
    end
  end

  describe '#render_xlsx via integration' do
    it 'sets the registered xlsx Mime type and the Content-Disposition filename' do
      get '/widgets.xlsx'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('spreadsheetml')
      expect(response.headers['Content-Disposition']).to include('widgets.xlsx')
    end
  end
end
