require 'base64'
require 'json'
require 'rest-client'
require 'socket'
require_relative 'request_pattern_builder'
require_relative 'mapping_builder'
require_relative 'response_definition_builder'

module WireMock
  def self.get_first_ip_not_in(*additional_ignored_ranges)
    ignore_ranges=['127.', '172.'] #Docker and localhost
    ignore_ranges.push(*additional_ignored_ranges)
    found=Socket.ip_address_list.detect do |intf|
      if intf.ipv4? and !intf.ipv4_loopback? and !intf.ipv4_multicast?
        ignore_ranges.bsearch{|r|intf.ip_address.start_with?(r)} == nil
      end
    end
    return found ? found.ip_address : nil
  end

  def stub_for (mapping_builder)
    raise 'Not implemented'
  end

  def given_that(mapping_builder)
    stub_for(mapping_builder)
  end

  # def request(method, matcher)
  #   MappingBuilder.new(RequestPatternBuilder.new(method, matcher))
  # end
  def get(matcher)
    MappingBuilder.new(RequestPatternBuilder.new('GET', matcher))
  end

  def post(matcher)
    MappingBuilder.new(RequestPatternBuilder.new('POST', matcher))
  end

  def put(matcher)
    MappingBuilder.new(RequestPatternBuilder.new('PUT', matcher))
  end

  def delete(matcher)
    MappingBuilder.new(RequestPatternBuilder.new('DELETE', matcher))
  end

  def url_matching(url_pattern)
    {'urlPattern' => url_pattern}
  end

  def url_equal_to(url)
    {'url' => url}
  end

  def a_response
    ResponseDefinitionBuilder.new
  end

  def equal_to(value)
    {'equalTo' => value}
  end

  def containing(value)
    {'contains' => value}
  end

  def matching(value)
    {'matches' => value}
  end

  def post_requested_for(matcher)
    RequestPatternBuilder.new('POST', matcher);
  end

  def get_requested_for(matcher)
    RequestPatternBuilder.new('GET', matcher);
  end

  def delete_requested_for(matcher)
    RequestPatternBuilder.new('DELETE', matcher);
  end

  def put_requested_for(matcher)
    RequestPatternBuilder.new('PUT', matcher);
  end

  def reset
    raise 'Not implemented'
  end

  class VerificationError < StandardError
    attr_reader :description
    def initialize(t)
      @description=t
    end
  end

end
