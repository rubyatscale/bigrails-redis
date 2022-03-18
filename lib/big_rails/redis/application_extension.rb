module BigRails
  module Redis
    module ApplicationExtension
      def redis
        @redis ||= Registry.new
      end
    end
  end
end
