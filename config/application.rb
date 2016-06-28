require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'roo'
require 'csv'

Bundler.require(*Rails.groups)

module Productbuilder
  class Application < Rails::Application
    config.action_dispatch.default_headers['P3P'] = 'CP="Not used"'
    config.action_dispatch.default_headers.delete('X-Frame-Options')
    config.assets.enabled = true
    config.active_record.raise_in_transactional_callbacks = true
  end
end
