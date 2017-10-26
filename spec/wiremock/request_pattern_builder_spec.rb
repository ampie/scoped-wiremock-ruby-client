require_relative '../../lib/wiremock/wiremock'
include WireMock
describe 'When matching two RequestPatternBuilders' do
  it 'should match two identical request paths' do
    one = WireMock::RequestPatternBuilder.new('GET', url_equal_to('/test/asdf'))
    two = WireMock::RequestPatternBuilder.new('GET', url_equal_to('/test/asdf'))
    expect(one.matches(two)).to be true
  end
  it 'should not match to differing request paths' do
    one = WireMock::RequestPatternBuilder.new('GET', url_equal_to('/test/asdf'))
    two = WireMock::RequestPatternBuilder.new('GET', url_equal_to('/test/asdfs'))
    expect(one.matches(two)).to be false
  end
  it 'should match two identical request patterns' do
    one = WireMock::RequestPatternBuilder.new('GET', url_matching('/test/asdf.*'))
    two = WireMock::RequestPatternBuilder.new('GET', url_matching('/test/asdf.*'))
    expect(one.matches(two)).to be true
  end
  it 'should not match to differing request patterns' do
    one = WireMock::RequestPatternBuilder.new('GET', url_matching('/test/asdf.*'))
    two = WireMock::RequestPatternBuilder.new('GET', url_matching('/test/asdfs.*'))
    expect(one.matches(two)).to be false
  end
  it 'should match a path with a request pattern' do
    one = WireMock::RequestPatternBuilder.new('GET', url_matching('/test/asdf/'))
    two = WireMock::RequestPatternBuilder.new('GET', url_matching('/test/as.*'))
    expect(one.matches(two)).to be false
  end
  it 'should always return a boolean' do
    one = WireMock::RequestPatternBuilder.new('POST', url_equal_to('/sbg-mobile/rest/SecurityService/CheckDevice'))
    two = WireMock::RequestPatternBuilder.new('ANY', url_matching('/sbg-mobile/rest.*'))
    one_matches = one.matches(two)
    expect(one_matches).to be true
  end
end

describe WireMock::RequestPatternBuilder do
  it 'should reflect a header that was added' do
    one = WireMock::RequestPatternBuilder.new('GET', url_equal_to('/test/asdf'))
    one.with_header('header1', 'foefie')
    build = one.build
    expect(build['headers']['header1']).to eq 'foefie'
  end
  it 'should reflect that no header was added' do
    one = WireMock::RequestPatternBuilder.new('GET', url_equal_to('/test/asdf'))
    build = one.build
    expect(build['headers']).to be_nil
  end
  it 'should reflect multiple headers that were added' do
    one = WireMock::RequestPatternBuilder.new('GET', url_equal_to('/test/asdf'))
    one.with_headers({'header1' => 'foefie', 'header2' => 'flaffie'})
    build = one.build
    expect(build['headers']['header1']).to eq 'foefie'
    expect(build['headers']['header2']).to eq 'flaffie'
  end
  it 'should reflect multiple headers that were added and then overridden' do
    one = WireMock::RequestPatternBuilder.new('GET', url_equal_to('/test/asdf'))
    one.with_headers({'header1' => 'foefie', 'header2' => 'flaffie'})
    one.with_header('header1', 'nope')
    build = one.build
    expect(build['headers']['header1']).to eq 'nope'
    expect(build['headers']['header2']).to eq 'flaffie'
  end
end
describe WireMock::MappingBuilder do
  it 'should reflect body value matchers' do
    one = WireMock::MappingBuilder.new(WireMock::RequestPatternBuilder.new('GET', url_equal_to('/test/asdf')))
    one.with_request_body(containing('valueToContain'))
    build = one.build
    expect(build['request']['bodyPatterns'].length).to be 1
    expect(build['request']['bodyPatterns'][0]['contains']).to eq 'valueToContain'
  end
end