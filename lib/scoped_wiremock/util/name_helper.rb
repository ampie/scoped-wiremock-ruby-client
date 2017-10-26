module ScopedWireMock
  module Util
    module NameHelper
      def path_friendly(name)
        name.gsub(/[^a-zA-Z0-9\/]/, '_').gsub(/\\/, '/')
      end
    end
  end
end