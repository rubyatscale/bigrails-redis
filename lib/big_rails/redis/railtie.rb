require "rails"

module BigRails
  module Redis
    class Railtie < Rails::Railtie
      config.before_configuration do |app|
        app.include(ApplicationExtension)
      end
    end
  end
end
