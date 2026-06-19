module Stradivari
  class Railtie < ::Rails::Engine
    initializer 'stradivari.active_record' do |app|
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.instance_eval do
          include Stradivari::Filter::Model::ActiveRecord
          include Stradivari::Table::Model::ActiveRecord
        end
      end
    end

    initializer 'stradivari.hawk' do |app|
      if defined?(::Hawk)
        Hawk::Model::Base.instance_eval do
          include Stradivari::Filter::Model::Hawk
          include Stradivari::Table::Model::Hawk
        end
      end
    end

    initializer 'stradivari.setup_helpers' do |app|
      app.config.to_prepare do
        # Guarded so the gem loads in apps that don't pull in the full stack
        # (e.g. api_only without ActionMailer) — was an unconditional NameError.
        ActionController::Base.send :helper, StradivariHelper if defined?(ActionController::Base)
        ActionMailer::Base.send     :helper, StradivariHelper if defined?(ActionMailer::Base)
      end
    end

    initializer 'stradivari.setup_mime_types' do |app|
      Mime::Type.register 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', :xlsx
    end
  end
end
