require 'base64'
require 'json'
require 'rest-client'

module WireMock
  class RequestPatternBuilder

    attr_reader :url_pattern, :http_method
    attr_writer :http_method

    def initialize(http_method, matcher)
      @http_method = http_method
      @url_pattern = matcher
    end

    def with_header(name, value_matcher)
      unless @header_patterns
        @header_patterns = {};
      end
      @header_patterns[name] = value_matcher
      self
    end

    def with_headers(headers)
      headers.each { |key, value| with_header(key, value) }
      self
    end

    def matches(other)
      if other.url_pattern['urlPattern'] then
        if @url_pattern['url']
          @url_pattern['url'] and (@url_pattern['url'].match(other.url_pattern['urlPattern']) != nil)
        else
          @url_pattern['urlPattern'] == other.url_pattern['urlPattern'] # not gonna try to figure this out
        end
      else
        @url_pattern['url'] and other.url_pattern['url'] and @url_pattern['url'] == other.url_pattern['url']
      end
    end

    def with_request_body(value_matcher)
      unless @body_patterns
        @body_patterns = [];
      end
      @body_patterns.push (value_matcher)
      self
    end

    def build
      request = {
          'method' => @http_method
      }
      if url_pattern['urlPattern']
        request['urlPattern'] = @url_pattern['urlPattern']
      else
        if url_pattern['url']
          request['url'] = @url_pattern['url']
        end
      end
      if @header_patterns
        request['headers'] = @header_patterns
      end
      if @body_patterns
        request['bodyPatterns'] = @body_patterns
      end
      request
    end
  end
end