# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Coverage edge cases' do
  let(:view) { view_context }

  describe 'Table::Generator sortable inactive direction' do
    before { create_widget }

    it 'defaults to asc for sortable columns that are not currently being sorted' do
      v = view_context
      v.singleton_class.send(:define_method, :sortable) { { sort: 'name', direction: 'asc' } }
      out = v.table_for(Widget.all) do
        column :price, sortable: true
      end
      doc = Nokogiri::HTML.fragment(out)
      th = doc.css('th.sortable').find { |t| t['data-sort'] == 'price' }
      expect(th['data-direction']).to eq('asc')
    end
  end

  describe 'Tabs::Generator force-present tabs' do
    it 'renders an empty tab when present: :force is set' do
      out = view.tabs_for([]) do |_|
        tab 'Forced', 'forced', [], present: :force do |_|
          haml_concat 'visible'
        end
      end
      expect(out).to include('visible')
      expect(out).to include('forced')
    end
  end

  describe 'XLSX::Controller trailing-newline HACK' do
    let(:dummy_controller_class) do
      Class.new(ApplicationController) do
        include Stradivari::XLSX::Controller

        def render_to_string(_opts)
          (+'fake-xlsx-bytes') << "\n" # ends with \n to trigger the slice! branch
        end

        def send_data(payload, _opts = {})
          @sent = payload
        end
        attr_reader :sent
      end
    end

    it 'slices the trailing newline and pads with NULs' do
      ctrl = dummy_controller_class.new
      ctrl.render_xlsx(filename: 'whatever')
      expect(ctrl.sent.bytesize).to eq('fake-xlsx-bytes'.bytesize + 4)
      expect(ctrl.sent.bytes.last(4)).to eq([0, 0, 0, 0])
    end
  end
end
