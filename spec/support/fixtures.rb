# frozen_string_literal: true

require "pathname"
require "ostruct"

module Spec
  module Support
    module Fixtures
      def load_config(type)
        allow(Rails).to receive(:application).and_return(
          OpenStruct.new(paths: {
            "config" => [Pathname.new("spec/fixtures/#{type}").expand_path]
          })
        )
      end
    end
  end
end

RSpec.configure do |config|
  config.include(Spec::Support::Fixtures)
end
