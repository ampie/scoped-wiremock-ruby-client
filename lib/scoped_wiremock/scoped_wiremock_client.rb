require_relative '../wiremock/wiremock'
require_relative 'util/mime_type_helper'
require_relative 'util/base_rest_client'
module ScopedWireMock
  CORRELATION_KEY_HEADER = 'x-sbg-messageTraceId'
  PROXY_UNMAPPED_ENDPOINTS  = 'automation.proxy.unmapped.endpoints'
  class ScopedWireMockClient < ScopedWireMock::Util::BaseRestClient
    include WireMock
    attr_reader :host, :port

    def initialize(base_url)
      super base_url
      @correlation_paths=[]
      @host=URI.parse(base_url).host
      @port=URI.parse(base_url).port
    end


    def start_new_global_scope( runName: 'test_run',
                                wireMockPublicUrl: ,
                                integrationScope: 'all',
                                urlOfServiceUnderTest: ,
                                globalJournaMode: 'NONE',
                                payload:{})
      params = method(__method__).parameters.map(&:last)
      opts = params.map {|p| [p, eval(p.to_s)]}.to_h
      execute(wire_mock_base_url + '/__admin/global_scopes/start', :post, opts)
    end

    def reset_all()
      execute(wire_mock_base_url + '/__admin/reset_all_scopes', :delete, {})
    end

    def stop_global_scope(runName:  'test_run',
                          wireMockPublicUrl: ,
                          sequenceNumber:  ,
                          urlOfServiceUnderTest:  ,
                          payload:  {})
      params = method(__method__).parameters.map(&:last)
      opts = params.map {|p| [p, eval(p.to_s)]}.to_h
      execute(wire_mock_base_url + '/__admin/global_scopes/stop', :post, opts)
    end

    def start_nested_scope(parent_correlation_path, name, payload)
      execute(wire_mock_base_url + '/__admin/scopes/start', :post, {
          :parentCorrelationPath=>parent_correlation_path,
          :name => name,
          :payload=>payload
      })
    end

    def stop_nested_scope(scope_path,payload)
      execute(wire_mock_base_url + '/__admin/scopes/stop', :post, {
          :correlationPath=>scope_path,
          :payload=>payload
      })
    end

    def start_user_scope(parent_correlation_path, name, payload)
      execute(wire_mock_base_url + '/__admin/user_scopes/start', :post, {
          :parentCorrelationPath=>parent_correlation_path,
          :name => name,
          :payload=>payload
      })
    end

    def get_correlated_scope(scope_path)
      execute(wire_mock_base_url + '/__admin/scopes/get', :post, {'correlationPath' => scope_path})
    end

    def register(extended_mapping_builder)
      execute(wire_mock_base_url + '/__admin/extended_mappings', :post, extended_mapping_builder.build)
    end
    #LEGACY


    def sync_correlated_scope(correlation_state)
      execute(wire_mock_base_url + '/__admin/scopes/sync', :post, correlation_state)
    end

    #Step management
    def start_step(scope_path, name)
      execute(wire_mock_base_url + '/__admin/scopes/steps/start', :post, {'correlationPath' => scope_path, 'currentStep' => name})
    end

    def stop_step(scope_path, name)
      execute(wire_mock_base_url + '/__admin/scopes/steps/stop', :post, {'correlationPath' => scope_path, 'currentStep' => name})
    end

    def find_exchanges_against_step(scope_path, name)
      execute(wire_mock_base_url + '/__admin/scopes/steps/find_exchanges', :post, {'correlationPath' => scope_path, 'currentStep' => name})
    end

    #Others
    def get_mappings_in_scope(scope_path)
      execute(wire_mock_base_url + '/__admin/scopes/mappings/find', :post, {'correlationPath' => scope_path})
    end

    def wire_mock_base_url
      'http://' + @host +':' + @port.to_s
    end



  end
end
