require_relative '../../lib/wiremock/wiremock'
include WireMock
describe 'When calculating the ip address' do
  it 'should find one ' do
    expect(WireMock.get_first_ip_not_in('127', '127')).to be_a String
  end

end