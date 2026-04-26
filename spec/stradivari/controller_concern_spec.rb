# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Stradivari::Controller, type: :request do
  describe 'default protected helpers' do
    let(:dummy_controller_class) do
      Class.new(ApplicationController) do
        include Stradivari::Controller

        def self.controller_name = 'widgets'

        def call_with(params_hash)
          @_params = ActionController::Parameters.new(params_hash)
          self
        end

        def params = @_params
      end
    end

    let(:ctrl) { dummy_controller_class.new }

    it '#default_sort_column returns "id"' do
      expect(ctrl.send(:default_sort_column)).to eq('id')
    end

    it '#default_sort_direction returns "ASC"' do
      expect(ctrl.send(:default_sort_direction)).to eq('ASC')
    end

    it '#sorting_object_class infers from controller_name' do
      expect(ctrl.send(:sorting_object_class)).to eq(Widget)
    end

    it '#sorting_object_class raises Stradivari::Error when class cannot be inferred' do
      no_model_class = Class.new(ApplicationController) do
        include Stradivari::Controller

        def self.controller_name = 'totally_unknown_things'
      end
      expect { no_model_class.new.send(:sorting_object_class) }
        .to raise_error(Stradivari::Error, /Can't infer/)
    end

    it '#stradivari_filter delegates to the model with stradivari_filter_options' do
      ctrl.call_with(q: { name_like: 'Widget 0' })
      create_widgets(2)
      expect(ctrl.send(:stradivari_filter, Widget).to_a.map(&:name)).to eq(['Widget 0'])
    end
  end

  describe 'GET /widgets with sort=nil' do
    it 'allows turning off sorting via sort=nil' do
      get '/widgets', params: { sort: 'nil' }
      expect(response).to have_http_status(:ok)
    end

    it 'rejects unsafe sort columns by falling back to default' do
      get '/widgets', params: { sort: 'evil; DROP TABLE' }
      expect(response).to have_http_status(:ok)
    end
  end
end
