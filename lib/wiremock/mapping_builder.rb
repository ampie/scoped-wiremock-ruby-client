# require 'rspec/expectations'
require 'base64'
require 'json'
require 'rest-client'

module WireMock
  class MappingBuilder
    attr_reader :request_pattern_builder,:response_definition_builder, :priority
    def initialize (request_builder)
      @request_pattern_builder = request_builder
    end
    def will_return(response_builder)
      @response_definition_builder = response_builder
      self
    end

    def with_header(name, value_matcher)
      request_pattern_builder.with_header(name, value_matcher)
      self
    end

    def with_headers(headers)
      request_pattern_builder.with_headers(headers)
      self
    end

    def at_priority(i)
      @priority = i
      self
    end

    def with_request_body(value_matcher)
      request_pattern_builder.with_request_body(value_matcher)
      self
    end

    def build
      result = {
          'request' => request_pattern_builder.build
      }
      result['response'] = @response_definition_builder.build unless @response_definition_builder.nil?
      result['priority'] = @priority if @priority

      result
    end

  end
end