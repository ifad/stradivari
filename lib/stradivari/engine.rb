module Stradivari
  class Railtie < ::Rails::Engine
    initializer 'stradivari.active_record' do |app|
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.extend Stradivari::Table::Models::ScopeSearch::Extensions
      end
    end
  end
end
