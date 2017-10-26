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


    def start_new_global_scope(global_correlation_state)
      execute(wire_mock_base_url + '/__admin/global_scopes/new', :post, global_correlation_state)
    end

    def reset_all()
      execute(wire_mock_base_url + '/__admin/reset_all_scopes', :delete, {})
    end

    def stop_correlated_scope(scope_path)
      execute(wire_mock_base_url + '/__admin/scopes/stop', :post, {'correlationPath' => scope_path})
    end
    #LEGACY
    def register(arg)
      execute(wire_mock_base_url + '/__admin/mappings', :post, mapping)
    end

    #Scope management
    def join_correlated_scope(known_scope_path)
      execute(wire_mock_base_url + '/__admin/scopes/join', :post, {'correlationPath' => known_scope_path})
    end

    def start_new_correlated_scope(parent_path)
      execute(wire_mock_base_url + '/__admin/scopes/new', :post, {'correlationPath' => parent_path})
    end

    def sync_correlated_scope(correlation_state)
      execute(wire_mock_base_url + '/__admin/scopes/sync', :post, correlation_state)
    end

    def stop_correlated_scope(scope_path)
      execute(wire_mock_base_url + '/__admin/scopes/stop', :post, {'correlationPath' => scope_path})
    end

    def get_correlated_scope(scope_path)
      execute(wire_mock_base_url + '/__admin/scopes/get', :post, {'correlationPath' => scope_path})
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
