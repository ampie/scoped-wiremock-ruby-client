require_relative '../wiremock/request_pattern_builder'
require_relative '../wiremock/wiremock'
module ScopedWireMock
  class ExtendedRequestPatternBuilder < WireMock::RequestPatternBuilder
    include WireMock
    attr_reader :url_info
    attr_accessor :correlation_path
    def initialize(http_method)
      super http_method, nil
      @url_info=nil
      @path_suffix=nil
      @url_is_pattern=false
      @to_all_known_external_services = false
      @endpoint_category=nil
      @correlation_path=nil
    end

    def to_any_known_external_service
      @to_all_known_external_services=true
      self
    end

    def to_any(category)
      to_any_known_external_service.of_category(category)
      self
    end

    def of_category(category)
      @endpoint_category=category
      self
    end

    def to_all_known_external_services?
      @to_all_known_external_services
    end

    def service
      self
    end

    def change_url_to_pattern
      @url_is_pattern=true
      @url_pattern=nil
      self
    end

    def to(url_info, path=nil)
      @url_info=url_info
      @path_suffix=path
      #now reset a couple of vars that might have depended on the old value
      @url_is_pattern=false
      @url_pattern=nil
      self
    end


    def clone
      result = super
      result.after_clone
      unless @header_patterns.nil?
        result.with_headers(@header_patterns)
      end
      unless @body_patterns.nil?
        @body_patterns.each {|b| b.result.with_request_body(b)}
      end
      result
    end

    def after_clone
      @header_patterns=nil
      @body_patterns=nil

    end

    def build
      result = {
          'method' => @http_method
      }
      if @url_pattern
        if url_pattern['urlPattern']
          result['urlPattern'] = @url_pattern['urlPattern']
        else
          if url_pattern['url']
            result['url'] = @url_pattern['url']
          end
        end
      end
      if @header_patterns
        result['headers'] = @header_patterns
      end
      if @body_patterns
        result['bodyPatterns'] = @body_patterns
      end
      result['endpointCategory'] = @endpoint_category
      result['pathSuffix'] = @path_suffix
      result['endpointCategory'] = @endpoint_category
      result['toAllKnownExternalServices'] = @to_all_known_external_services
      result['urlInfo'] = @url_info
      result['urlIsPattern'] = @url_is_pattern
      result
    end

  end

end