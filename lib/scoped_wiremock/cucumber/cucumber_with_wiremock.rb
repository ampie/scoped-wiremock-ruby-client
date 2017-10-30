require 'cucumber/formatter/json'
require_relative '../../../lib/scoped_wiremock/extended_mapping_builder'
require_relative '../../../lib/scoped_wiremock/strategies/response_strategies'
require_relative '../../../lib/scoped_wiremock/strategies/requests'
require_relative '../scoped_wiremock_client'
require 'calabash-android/operations'
module ScopedWireMock
  class MyOperations
    include Calabash::Android::Operations

  end
  class WireMockFromCucumber < ScopedWireMock::ScopedWireMockClient
    attr_accessor :current_scope
    def initialize(base_url)
      super
      @current_scope=[]
    end
    def register (mapping)
      correlation_path = current_scope.last()['correlationPath']
      mapping.request_pattern_builder.correlation_path = correlation_path
      mapping.request_pattern_builder.with_header(ScopedWireMock::CORRELATION_KEY_HEADER,matching(correlation_path + '.*guest'))
      super(mapping)
    end
  end
  class CucumberWithWireMock < Cucumber::Formatter::Json
    include ScopedWireMock::Strategies::ResponseStrategies
    include ScopedWireMock::Strategies::Requests
    def self.wiremock
      @@wiremock_client
    end

    def initialize(config)
      super
      @paths = config.paths
      @@wiremock_client = ScopedWireMock::WireMockFromCucumber.new 'http://172.17.0.1:8083'
      @global_scope=@@wiremock_client.start_new_global_scope(
          run_name: 'androidend2end_regression',
          wiremock_public_url: 'http://172.17.0.1:8083',
          url_of_service_under_test: 'http://172.17.0.1:8080/eap-domain-service',
          global_journal_mode: 'NONE',
          integration_scope:'showcase'
      )
      @@wiremock_client.current_scope << @global_scope
      @feature_count = 0
      @feature_element_count =0
    end

    def on_before_test_case(event)
      super
      if (@feature_hashes.size > @feature_count)
        unless @feature_count==0
          @@wiremock_client.stop_nested_scope @feature_scope['correlationPath'], {}
          @@wiremock_client.current_scope.pop
        end
        @feature_count = @feature_hashes.size
        @feature_element_count =0
        @feature_hash[:uri]=relative_uri_of(event.test_case.feature.file)
        @feature_hash[:method]='feature'
        @feature_scope = @@wiremock_client.start_nested_scope @global_scope['correlationPath'], @feature_hash[:id], @feature_hash
        @@wiremock_client.current_scope << @feature_scope
      end
      mapping = any_request().to_any('external').service().will(map_to_journal_directory('external'))
      @@wiremock_client.register mapping
      mapping = any_request().to('/eap-domain-service').will(proxy_to('http://eap-domain-service:8080'))
      @@wiremock_client.register mapping
      @element_hash[:method]='featureElement'
      @test_case_scope=@@wiremock_client.start_nested_scope @feature_scope['correlationPath'], @element_hash[:id], @element_hash
      @@wiremock_client.current_scope << @test_case_scope
      @@wiremock_client.start_user_scope @test_case_scope['correlationPath'], 'guest'
      operations=ScopedWireMock::MyOperations.new
      operations.uninstall_apps
      operations.install_app(ENV['TEST_APP_PATH'])
      operations.install_app(ENV['APP_PATH'])
      operations.start_test_server_in_background
      operations.backdoor 'setCorrelationPath', @test_case_scope['correlationPath'] + "/:guest"

    end

    def relative_uri_of(feature_file)
      return feature_file if (@paths.empty?)
      @paths.each do |path|
        if (feature_file.start_with?(path))
          return feature_file.slice(path.size, feature_file.size - path.size)
        end
      end
    end

    def on_before_test_step(event)
      super
      test_step = event.test_step
      unless internal_hook?(test_step)
        @step_or_hook_hash[:method]='step'
        @@wiremock_client.start_step @test_case_scope['correlationPath'], test_step.name, @step_or_hook_hash
      end
    end

    def on_after_test_step(event)
      super
      test_step = event.test_step
      unless internal_hook?(test_step)
        @step_or_hook_hash[:method]='matchAndResult'
        @@wiremock_client.stop_step @test_case_scope['correlationPath'], test_step.name, @step_or_hook_hash
      end
    end

    def on_after_test_case(event)
      super
      @@wiremock_client.current_scope.pop
      @@wiremock_client.stop_nested_scope @test_case_scope['correlationPath'], @element_hash
    end

    def on_finished_testing(event)
      #no super because we don't want to dump the json
      @global_scope=@@wiremock_client.stop_global_scope(
          run_name: @global_scope['runName'],
          wiremock_public_url: @global_scope['wireMockPublicUrl'],
          url_of_service_under_test: @global_scope['urlOfServiceUnderTest'],
          sequence_number: @global_scope['sequenceNumber']
      )
    end

    private
    def internal_hook?(test_step)
      test_step.source.last.location.file.include?('lib/cucumber/')
    end
  end
end
