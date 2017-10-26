module ScopedWireMock
  module Util
    module MimeTypeHelper
      def calculate_extension(headers)
        if content_type = headers['Content-Type'].nil?
          '.txt'
          else
          content_type = headers['Content-Type']
          if content_type.include?('xml')
            '.xml'
          elsif content_type.include?('json')
            '.json'
          else
            '.txt'
          end
        end
      end

      def determine_content_type(file_name)
        if file_name.end_with? '.xml'
          'application/xml'
        elsif file_name.end_with? '.json'
          'application/json'
        else
          'text/plain'
        end
      end
    end
  end
end