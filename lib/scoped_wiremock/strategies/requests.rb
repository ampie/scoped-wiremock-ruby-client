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
        builder = ScopedWireMock::ExtendedMappingBuilder.new(current_scope.current_user_scope, method)
        builder.init_sequential_command
        builder
      end
    end
  end
end