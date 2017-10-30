require 'uri'
require_relative '../../lib/scoped_wiremock/scoped_wiremock_client'
require_relative '../../lib/scoped_wiremock/extended_mapping_builder'
require_relative '../../lib/scoped_wiremock/strategies/response_strategies'


describe ScopedWireMock::ExtendedMappingBuilder do
  include ScopedWireMock::Strategies::ResponseStrategies
  DOCKER_HOST=WireMock.get_first_ip_not_in('172', '127')
  it 'should build a global journal recording rule' do
    #given: 'a global recording ExtendedStubMapingBuilder'
    request_builder = ScopedWireMock::ExtendedRequestPatternBuilder.new('ANY').to_any('feb').service()

    builder = ScopedWireMock::ExtendedMappingBuilder.new(request_builder)
                 .will(map_to_journal_directory('directory1'))

    #when: 'I generate the stub mapping'

    stub_mapping = builder.build()
    #then: 'the stubmapping should reflect the journal recording rule'
    puts stub_mapping.to_json
    expect(stub_mapping['recordingSpecification']['enforceJournalModeInScope']).to be true
    expect(stub_mapping['recordingSpecification']['recordingDirectory']).to eq 'directory1'
    expect(stub_mapping['localPriority']).to eq 'JOURNAL'
    expect(stub_mapping['extendedRequest']['urlPattern']).to be nil
    expect(stub_mapping['extendedRequest']['toAllKnownExternalServices']).to be true
    expect(stub_mapping['extendedRequest']['endpointCategory']).to eq 'feb'

    wiremock_client= ScopedWireMock::ScopedWireMockClient.new("http://#{DOCKER_HOST}:8083")
    wiremock_client.reset_all
    #given: 'a global scope'
    global_scope = wiremock_client.start_new_global_scope(
        run_name:  'android_regression',
        wiremock_public_url:  "http://#{DOCKER_HOST}:8083",
        integration_scope:  'something',
        url_of_service_under_test:  "http://#{DOCKER_HOST}:8080",
        global_journal_mode:  'RECORD')


    request_builder.correlation_path=global_scope['correlationPath']

    wiremock_client.register(builder)

  end
end