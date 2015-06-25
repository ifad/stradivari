module Stradivari
  class Railtie < ::Rails::Engine
    initializer 'stradivari.active_record' do |app|
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.include Stradivari::Filter::Model::ScopeSearch

        case ActiveRecord::VERSION::MAJOR
        when 3
          ActiveRecord::Base.extend Stradivari::Filter::Model::Rails3
        when 4
          ActiveRecord::Base.extend Stradivari::Filter::Model::Rails4
        else
          raise Error
        end
      end
    end

    initializer 'stradivari.setup_helpers' do |app|
      app.config.to_prepare do
        ActionController::Base.send :helper, StradivariHelper
      end
    end

    initializer 'stradivari.setup_mime_types' do |app|
      Mime::Type.register 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', :xlsx
    end
  end
end
