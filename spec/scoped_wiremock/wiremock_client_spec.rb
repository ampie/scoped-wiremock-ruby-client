require 'uri'
require_relative '../../lib/scoped_wiremock/scoped_wiremock_client'


describe ScopedWireMock::ScopedWireMockClient do
  DOCKER_HOST=WireMock.get_first_ip_not_in('172', '127')

  it 'should start a new global scope' do
    wiremock_client= ScopedWireMock::ScopedWireMockClient.new("http://#{DOCKER_HOST}:8083")
    wiremock_client.reset_all
    #given: 'a service under test'
    #when: 'I start a new global scope'
    result_global_scope = wiremock_client.start_new_global_scope(
        run_name: 'android_regression',
        wiremock_public_url:  "http://#{DOCKER_HOST}:8083",
        integration_scope: 'something',
        url_of_service_under_test: "http://#{DOCKER_HOST}:8080",
        global_journal_mode: 'RECORD',
        payload: {prop1: 'val1'}
    )
    #then: 'the correlation path must reflect the WireMock host name, port, the testRunName and the number 0'
    expect(result_global_scope['correlationPath']).to eq "#{DOCKER_HOST}/8083/android_regression/0"
    expect(result_global_scope['payload']['prop1']).to eq 'val1'

  end

  it 'should start multiple concurrent global scopes' do
    wiremock_client= ScopedWireMock::ScopedWireMockClient.new("http://#{DOCKER_HOST}:8083")
    wiremock_client.reset_all
    #given: 'a service under test'
    #when: 'I start a new global scope'
    result_global_scope1 = wiremock_client.start_new_global_scope(
        run_name:  'android_regression',
        wiremock_public_url:  "http://#{DOCKER_HOST}:8083",
        integration_scope:  'something',
        url_of_service_under_test:  "http://#{DOCKER_HOST}:8080",
        global_journal_mode:  'RECORD'

    )
    result_global_scope2 = wiremock_client.start_new_global_scope(
        run_name:  'android_regression',
        wiremock_public_url:  "http://#{DOCKER_HOST}:8083",
        integration_scope:  'something',
        url_of_service_under_test:  "http://#{DOCKER_HOST}:8080",
        global_journal_mode:  'RECORD'

    )
    #then: 'the correlation path must reflect the WireMock host name, port, the testRunName and the number 1'
    expect(result_global_scope1['correlationPath']).to eq "#{DOCKER_HOST}/8083/android_regression/0"
    expect(result_global_scope2['correlationPath']).to eq "#{DOCKER_HOST}/8083/android_regression/1"
  end

  it 'should stop a global scope' do
    wiremock_client= ScopedWireMock::ScopedWireMockClient.new("http://#{DOCKER_HOST}:8083")
    wiremock_client.reset_all
    #given: 'a service under test'
    #and" 'a global scope'
    result_global_scope = wiremock_client.start_new_global_scope(
        run_name:  'android_regression',
        wiremock_public_url:  "http://#{DOCKER_HOST}:8083",
        integration_scope:  'something',
        url_of_service_under_test:  "http://#{DOCKER_HOST}:8080",
        global_journal_mode:  'RECORD'

    )
    #when: 'I stop the global scope'
    stopped_scope=wiremock_client.stop_global_scope(run_name:  'android_regression',
                                                    wiremock_public_url:  "http://#{DOCKER_HOST}:8083",
                                                    sequence_number:  result_global_scope['sequenceNumber'],
                                                    url_of_service_under_test:  "http://#{DOCKER_HOST}:8080",
                                                    payload:  {prop1:  'val1'}
    )
    #then: 'the correlation path must reflect the WireMock host name, port, the testRunName and the number 1'
    expect(stopped_scope['correlationPath']).to eq "#{DOCKER_HOST}/8083/android_regression/0"
    expect(stopped_scope['payload']['prop1']).to eq 'val1'
  end

  it 'should start a nested scope' do
    wiremock_client= ScopedWireMock::ScopedWireMockClient.new("http://#{DOCKER_HOST}:8083")
    wiremock_client.reset_all
    #given: 'a global scope'
    global_scope = wiremock_client.start_new_global_scope(
        run_name:  'android_regression',
        wiremock_public_url:  "http://#{DOCKER_HOST}:8083",
        integration_scope:  'something',
        url_of_service_under_test:  "http://#{DOCKER_HOST}:8080",
        global_journal_mode:  'RECORD'

    )

    #when: 'I start a nested scope'
    nested_scope = wiremock_client.start_nested_scope(global_scope['correlationPath'], 'nested1', {'prop1' => 'val1'})

    #then: 'the correlation path must reflect the WireMock host name, port, the testRunName and the number 1'
    expect(nested_scope['correlationPath']).to(eq(global_scope['correlationPath'] + '/nested1'))
    retrieved_scope=wiremock_client.get_correlated_scope(nested_scope['correlationPath'])
    expect(nested_scope['correlationPath']).to(eq(retrieved_scope['correlationPath']))
  end

  it 'should start a nested scope within another nested scope' do
    wiremock_client= ScopedWireMock::ScopedWireMockClient.new("http://#{DOCKER_HOST}:8083")
    wiremock_client.reset_all
    #given: 'a global scope'
    global_scope = wiremock_client.start_new_global_scope(
        run_name:  'android_regression',
        wiremock_public_url:  "http://#{DOCKER_HOST}:8083",
        integration_scope:  'something',
        url_of_service_under_test:  "http://#{DOCKER_HOST}:8080",
        global_journal_mode:  'RECORD'
    )

    #when: 'I start a nested scope within another nested scope'
    feature_scope = wiremock_client.start_nested_scope(global_scope['correlationPath'], 'feature1', {'prop1' => 'val1'})
    scenario_scope = wiremock_client.start_nested_scope(feature_scope['correlationPath'], 'scenario1', {'prop1' => 'val1'})


    #then: 'the correlation path must reflect the WireMock host name, port, the testRunName and the number 1'
    expect(scenario_scope['correlationPath']).to(eq(global_scope['correlationPath'] + '/feature1/scenario1'))
    retrieved_scope=wiremock_client.get_correlated_scope(scenario_scope['correlationPath'])
    expect(scenario_scope['correlationPath']).to(eq(retrieved_scope['correlationPath']))
  end


  it 'should stop a nested scope' do
    wiremock_client= ScopedWireMock::ScopedWireMockClient.new("http://#{DOCKER_HOST}:8083")
    wiremock_client.reset_all
    #given: 'a global scope'
    global_scope = wiremock_client.start_new_global_scope(
        run_name:  'android_regression',
        wiremock_public_url:  "http://#{DOCKER_HOST}:8083",
        integration_scope:  'something',
        url_of_service_under_test:  "http://#{DOCKER_HOST}:8080",
        global_journal_mode:  'RECORD'

    )

    #and: 'a nested scope'
    nested_scope = wiremock_client.start_nested_scope(global_scope['correlationPath'], 'nested1', {'prop1' => 'val1'})
    #when: 'I stop the nested scope'
    wiremock_client.stop_nested_scope(nested_scope['correlationPath'], {'prop1' => 'val1'})
    #then: 'the correlation path must reflect the WireMock host name, port, the testRunName and the number 1'
    expect(nested_scope['correlationPath']).to(eq(global_scope['correlationPath'] + '/nested1'))
  end

  it 'should start a guest scope' do
    wiremock_client= ScopedWireMock::ScopedWireMockClient.new("http://#{DOCKER_HOST}:8083")
    wiremock_client.reset_all
    #given: 'a global scope'
    global_scope = wiremock_client.start_new_global_scope(
        run_name:  'android_regression',
        wiremock_public_url:  "http://#{DOCKER_HOST}:8083",
        integration_scope:  'something',
        url_of_service_under_test:  "http://#{DOCKER_HOST}:8080",
        global_journal_mode:  'RECORD'
    )

    #and: 'a nested scope'
    nested_scope = wiremock_client.start_nested_scope(global_scope['correlationPath'], 'nested1', {'prop1' => 'val1'})
    #when: 'I stop the nested scope'
    user_scope = wiremock_client.start_user_scope(nested_scope['correlationPath'],'guest', {'prop1' => 'val1'})
    puts user_scope.to_json
    #then: 'the correlation path must reflect the WireMock host name, port, the testRunName and the number 1'
    expect(user_scope['correlationPath']).to(eq(nested_scope['correlationPath'] + '/:guest'))
  end

end