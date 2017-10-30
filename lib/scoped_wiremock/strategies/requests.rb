require_relative '../extended_mapping_builder'

module ScopedWireMock
  module Strategies
    module Requests
      def all_requests
        a('ANY')
      end

      def any_request
        a('ANY')
      end

      def a(method)
        builder = ScopedWireMock::ExtendedMappingBuilder.new(ScopedWireMock::ExtendedRequestPatternBuilder.new(method))
        builder
      end
    end
  end
end