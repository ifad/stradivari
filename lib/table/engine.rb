module Table
  class Railtie < ::Rails::Engine
    initializer 'table.active_record' do |app|
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.extend ::Table::Models::ScopeSearch::Extensions
      end
    end
  end
end
