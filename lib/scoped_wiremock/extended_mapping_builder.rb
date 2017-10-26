require 'pathname'
require_relative '../wiremock/wiremock'
require_relative '../wiremock/mapping_builder'
require_relative 'extended_request_pattern_builder'
require_relative 'recording_specification'
module ScopedWireMock
  class ExtendedMappingBuilder < WireMock::MappingBuilder
    include WireMock
    attr_reader :request_pattern_builder, :recording_specification, :count_matching_strategy
    attr_writer :request_pattern_builder,
        def initialize(method)
          @nested_scopes = []
          @request_pattern_builder=ExtendedRequestPatternBuilder.new(method)
        end

    def to_any_known_external_service
      request_pattern_builder.to_any_known_external_service
      self
    end

    def to_all_known_external_services?
      request_pattern_builder.to_all_known_external_services?
    end

    def change_url_to_pattern
      request_pattern_builder.change_url_to_pattern
      self
    end

    def to(url_info, path=nil)
      request_pattern_builder.to(url_info, path)
      self
    end

    def recording_specification
      @recording_specification=RecordingSpecification.new if @recording_specification.nil?
      @recording_specification
    end

    def recording_directory
      recording_specification.recording_directory
    end

    def journal_mode_override
      recording_specification.journal_mode_override
    end

    def record_to_current_resource_dir?
      recording_specification.record_to_current_resource_dir?
    end

    def enforce_journal_mode_in_scope?
      recording_specification.enforce_journal_mode_in_scope?
    end

    def recording_responses
      recording_specification.recording_responses
      self
    end

    def recording_responses_to(directory)
      recording_specification.recording_responses_to(directory)
      self
    end

    def playing_back_responses
      recording_specification.playing_back_responses
      self
    end

    def playing_back_responses_from(directory)
      recording_specification.playing_back_responses_from(directory)
      self
    end

    def maps_to_journal_directory(journal_directory)
      recording_specification.maps_to_journal_directory(journal_directory)
      change_url_to_pattern
      self
    end

    def was_made(count_matcher)
      and_verify_that(count_matcher)
    end

    def and_verify_that(count_matcher)
      @count_matching_strategy=count_matcher
      self
    end

    def add_child_builder(child)
      @nested_scopes << child
    end


    def will(proc)
      @response_definition_builder=proc.call(self, @mocking_context)
      unless @response_definition_builder.nil? or @response_definition_builder.is_a? ResponseDefinitionBuilder
        raise 'The response strategy Proc must return a ResponseDefinitionBuilder'
      end
      will_return(@response_definition_builder)
    end


  end
end