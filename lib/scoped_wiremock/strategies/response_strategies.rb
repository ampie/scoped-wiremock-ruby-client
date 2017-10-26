require 'mustache'
require_relative '../../scoped_wiremock/'
require_relative '../../wiremock/wiremock'
module ScopedWireMock
  module Strategies
    module ResponseStrategies
      include WireMock


      # if the JournalMode in scope is PLAYBACK, this will load all the journal entries in the current journal directory, BEFORE any other callbacks/steps are called
      # if the JournalMode in scope is RECORD, this will save all the journal entries in the current journal directory, AFTER all other callbacks in scope have been called
      def map_to_journal_directory(journal_directory)
        Proc.new do |builder, scope|
          builder.change_url_to_pattern
          builder.maps_to_journal_directory(journal_directory)
          builder.at_priority(scope.calculate_priority(1))
          nil
        end
      end

      def playback_responses_from(recording_directory)
        Proc.new do |builder, scope|
          builder.change_url_to_pattern
          builder.playing_back_responses_from(recording_directory)
          builder.at_priority(scope.calculate_priority(2))
          nil
        end
      end

      def playback_responses
        Proc.new do |builder, scope|
          builder.change_url_to_pattern
          builder.playing_back_responses
          builder.at_priority(scope.calculate_priority(2))
          nil
        end
      end

      def record_responses
        Proc.new do |builder, scope|
          builder.change_url_to_pattern
          builder.recording_responses
          builder.at_priority(scope.calculate_priority(2))
          nil
        end
      end
      def record_responses_to (directory)
        Proc.new do |builder, scope|
          builder.change_url_to_pattern
          builder.recording_responses_to(directory)
          builder.at_priority(scope.calculate_priority(2))
          nil
        end
      end

      def return_the_body(body, content_type)
        Proc.new do |builder, scope|
          builder.at_priority(scope.calculate_priority(3))
          response_with_default_headers(scope).with_body(body).with_header('Content-Type', content_type)
        end
      end

      def return_the_file(file_name)
        Proc.new do |builder, scope|
          if Pathname.new(file_name).absolute?
            body_file=file_name
          else
            body_file = scope.resolve_resource(file_name)
          end
          body_content=File.read(body_file)
          headers=read_headers(body_file)
          builder.at_priority(scope.calculate_priority(3))
          response_builder = response_with_default_headers(scope).with_body(body_content).with_header('Content-Type', determine_content_type(file_name))
          unless headers.nil?
            response_builder.with_headers(JSON.parse(headers))
          end
          response_builder
        end
      end
      def read_headers(response_file_path)
        headers_file=response_file_path.slice(0, response_file_path.length - File.extname(response_file_path).length) + '.headers.json'
        if File.exist? headers_file
          File.read(headers_file)
        else
          nil
        end
      end

      def merge(template_builder)
        Proc.new do |builder, scope|
          if Pathname.new(template_builder.file_name).absolute?
            template_file = template_builder.file_name
          else
            template_file = scope.resolve_resource(template_builder.file_name)
          end
          template_content=File.read(template_file)
          headers=read_headers(template_file)
          response_body=Mustache.render(template_content, template_builder.variables)
          builder.at_priority(scope.calculate_priority(3))
          response_with_default_headers(scope).with_body(response_body).with_header('Content-Type', determine_content_type(template_builder.file_name))
        end
      end

      def the_template(template_file_name)
        ScopedWireMock::TemplateBuilder.new(template_file_name)
      end


      def be_intercepted
        Proc.new do |builder, scope|
          if builder.to_all_known_external_services?
            scope.all_known_external_endpoints.each_pair do |key, value|
              url = URI.parse(value)
              new_builder = ScopedWireMock::ExtendedMappingBuilder.new(nil, 'ANY').to(url.path + '.*')
              proxied_base_url = build_base_url(url)
              new_builder.at_priority(scope.calculate_priority(5)).will_return(a_response.proxied_from(proxied_base_url))
              builder.add_child_builder(new_builder)
            end
            nil
          else
            url=URI.parse(scope.endpoint_url_for(builder.request_pattern_builder.url_info))
            builder.to(url.path).change_url_to_pattern
            proxied_base_url = build_base_url(url)
            builder.at_priority(scope.calculate_priority(5))
            a_response.proxied_from(proxied_base_url)
          end
        end
      end

      def build_base_url(url)
        url.scheme + '://' + url.host + ':' + url.port.to_s
      end

      def response_with_default_headers(user_scope)
        a_response
      end
    end
  end
end