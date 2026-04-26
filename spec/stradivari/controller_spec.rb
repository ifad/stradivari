require 'spec_helper'

RSpec.describe WidgetsController, type: :request do
  before do
    create_widgets(3)
  end

  describe 'GET /widgets (HTML)' do
    it 'renders the filter, table, and tabs' do
      get '/widgets'
      expect(response).to have_http_status(:ok)

      doc = html(response.body)
      # Filter form
      form = doc.at_css('form#filter-form')
      expect(form).not_to be_nil
      expect(form.at_css('input[name="sort"]')).not_to be_nil
      expect(form.at_css('input[name="direction"]')).not_to be_nil
      # Table with all created rows
      expect(doc.css('table.table tbody tr').size).to eq(3)
      # `row` block contributed data attributes
      first_row = doc.at_css('table.table tbody tr')
      expect(first_row['data-widget-id']).to match(/\A\d+\z/)
      # Sortable header for `name`
      expect(doc.at_css('table.table thead th.name.sortable')).not_to be_nil
      # Download link in footer (downloadable: :xlsx)
      expect(doc.at_css('.download a')).not_to be_nil
      expect(doc.at_css('.download a')['href']).to match(/\.xlsx|format=xlsx/)
      # Tabs widget rendered
      expect(doc.at_css('ul.nav.nav-tabs')).not_to be_nil
      expect(doc.at_css('.tab-content')).not_to be_nil
    end

    it 'sorts according to params and propagates direction toggle' do
      get '/widgets', params: { sort: 'name', direction: 'desc' }
      doc = html(response.body)
      header = doc.at_css('table.table thead th.name.sortable')
      expect(header['data-sort']).to eq('name')
      # When the active direction is desc, the next click should toggle to asc
      expect(header['data-direction']).to eq('asc')
      expect(header['class']).to include('active-column')
    end

    it 'rejects unknown sort columns and falls back to default' do
      get '/widgets', params: { sort: 'evil_injection' }
      expect(response).to have_http_status(:ok)
      # Output should still contain the table; default sort header is "name"
      doc = html(response.body)
      expect(doc.at_css('table.table thead th.name')).not_to be_nil
    end

    it 'filters via stradivari scopes' do
      get '/widgets', params: { q: { name_like: 'Widget 1' } }
      doc = html(response.body)
      rows = doc.css('table.table tbody tr')
      expect(rows.size).to eq(1)
    end
  end

  describe 'GET /widgets.csv' do
    it 'returns CSV content' do
      get '/widgets.csv'
      expect(response).to have_http_status(:ok)
      parsed = ::CSV.parse(response.body)
      # Header + 3 rows (when no children)
      expect(parsed.first).to eq(%w[Id Name Price])
      expect(parsed.size).to eq(4)
    end
  end

  describe 'GET /widgets.xlsx' do
    it 'returns a parseable XLSX with the expected content' do
      get '/widgets.xlsx'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('spreadsheetml')
      rows = xlsx_rows(response.body)
      expect(rows.size).to eq(3)
      open_xlsx(response.body) do |sheet|
        expect(sheet.row(1)).to eq(['Id', 'Name', 'Price'])
      end
    end

    it 'sets the filename via Content-Disposition' do
      get '/widgets.xlsx'
      expect(response.headers['Content-Disposition']).to include('widgets.xlsx')
    end
  end

  describe 'GET /widgets/:id' do
    it 'renders details_for' do
      widget = Widget.first
      get "/widgets/#{widget.id}"
      doc = html(response.body)
      dl = doc.at_css('dl.dl-horizontal')
      expect(dl).not_to be_nil
      labels = dl.css('dt').map(&:text)
      expect(labels).to include('Name', 'Price', 'Released on')
    end
  end
end
