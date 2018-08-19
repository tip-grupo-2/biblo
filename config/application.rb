require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module BibliotecaPopular
  class Application < Rails::Application
    config.generators do |generate|
      generate.assets false
      generate.view_specs false
      generate.helper_specs false
      generate.routing_specs false
      generate.controller_specs false
    end
    config.active_record.raise_in_transactional_callbacks = true
  end
end
