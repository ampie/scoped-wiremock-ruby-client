require 'uri'
require_relative '../../lib/scoped_wiremock/scoped_wiremock_client'


describe ScopedWireMock::ScopedWireMockClient do


  it 'should start a new global scope' do
    #TODO get rid of hard-code IP address
    wiremock_client= ScopedWireMock::ScopedWireMockClient.new('http://192.168.89.205:8083')
    wiremock_client.reset_all
    #given: 'a service under test'
    #when: 'I start a new global scope'
    global_scope_initial_state = {
        :runName=>'android_regression',
        :wireMockPublicUrl=>'http://192.168.89.205:8083',
        :integrationScope => 'something',
        :urlOfServiceUnderTest=>'http://192.168.89.205:8080',
        :globalJournaMode=>'RECORD'

    }
    result_global_scope = wiremock_client.start_new_global_scope(global_scope_initial_state)
    #then: 'the correlation path must reflect the WireMock host name, port, the testRunName and a 0 number'
    puts result_global_scope.to_json
    expect(result_global_scope['correlationPath']).to eq '192.168.89.205/8083/android_regression/2'
  end


end