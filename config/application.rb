require_relative 'boot'

# Substitua 'require "rails/all"' pelas linhas abaixo
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"
# require 'active_graph'
# Não requira o active_record/railtie
# require "active_record/railtie"  # Esta linha deve ser comentada ou removida

Bundler.require(*Rails.groups)

module BudgetApp
  class Application < Rails::Application
    config.load_defaults 7.0

    # Suas outras configurações...
  end
end
