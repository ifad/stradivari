module Stradivari
  class Railtie < ::Rails::Engine
    initializer 'stradivari.active_record' do |app|
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.extend Stradivari::Table::Models::ScopeSearch::Extensions
      end
    end

    initializer 'stradivari.setup_helpers' do |app|
      app.config.to_prepare do
        ActionController::Base.send :helper, StradivariHelper
      end
    end
  end
end
