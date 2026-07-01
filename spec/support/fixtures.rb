# frozen_string_literal: true

module Spec
  module Support
    module Fixtures
      def load_config(type)
        paths = {
          "config" => [Pathname.new("spec/fixtures/#{type}").expand_path]
        }
        application = double("Rails.application", paths: paths)
        allow(Rails).to receive(:application).and_return(application)
      end
    end
  end
end

RSpec.configure do |config|
  config.include(Spec::Support::Fixtures)
end
