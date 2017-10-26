
module ScopedWireMock
    module Strategies
    module Verification
      def verify_that(recording_mapping_builder)
        user_scope = current_scope.current_user_scope
        user_scope.verify_rule(recording_mapping_builder)
      end
      def exactly(count)
        ExactMatcher.new(count)
      end
      def at_least(count)
        AtLeastMatcher.new(count)
      end
      def once
        1
      end
      def twice
        2
      end
      class BaseCountMatcher
        def times
          self
        end
        def requests_were_made
          self
        end
        def request_was_made
          self
        end
      end
      class ExactMatcher < BaseCountMatcher
        def initialize(count)
          @count=count
        end
        def === (actual)
          return @count==actual
        end
        def description
          "Exactly #{@count}"
        end
      end
      class AtLeastMatcher  < BaseCountMatcher
        def initialize(count)
          @count=count
        end
        def === (actual)
          return @count <= actual
        end
        def description
          "At Least #{@count}"
        end
      end
    end
  end
end