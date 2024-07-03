require_relative 'boot'

require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module BudgetApp
  class Application < Rails::Application
    config.load_defaults 7.0
  end
end
