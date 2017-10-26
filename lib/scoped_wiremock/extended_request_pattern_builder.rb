require_relative '../wiremock/request_pattern_builder'
require_relative '../wiremock/wiremock'
module ScopedWireMock
  class ExtendedRequestPatternBuilder < WireMock::RequestPatternBuilder
    include WireMock
    attr_reader :url_info

    def initialize( http_method)
      super http_method, nil
      @url_info=nil
      @path_suffix=nil
      @url_is_pattern=false
      @to_all_known_external_services = false
    end

    def ensure_scope_path(pattern)
      @header_patterns={} if @header_patterns.nil?
      if @header_patterns[ScopedWireMock::CORRELATION_KEY_HEADER].nil?
        with_header(ScopedWireMock::CORRELATION_KEY_HEADER, pattern)
      end
    end

    def to_any_known_external_service
      @to_all_known_external_services=true
      @url_info='.*'
      self
    end

    def to_all_known_external_services?
      @to_all_known_external_services
    end

    def change_url_to_pattern
      @url_is_pattern=true
      @url_pattern=nil
      self
    end

    def to(url_info, path=nil)
      @url_info=url_info
      @path_suffix=path
      #now reset a couple of vars that might have depended on the old value
      @url_is_pattern=false
      @url_pattern=nil
      self
    end

    def url_pattern
      if @url_pattern.nil?
        path = @url_info
        if is_property_name?(path)
          uri = URI.parse(@mocking_context.endpoint_url_for(path))
          path=uri.path
          puts(path)
        end
        path = path + @path_suffix if @path_suffix
        if @url_is_pattern and not path.end_with?('.*')
          path = path + '.*'
        end
        if (path.match(/\.\*/))
          @url_pattern = url_matching(path)
        else
          @url_pattern = url_equal_to(path)
        end
      end
      @url_pattern
    end

    def clone
      result = super
      result.after_clone
      unless @header_patterns.nil?
        result.with_headers(@header_patterns)
      end
      unless @body_patterns.nil?
        @body_patterns.each {|b| b.result.with_request_body(b)}
      end
      result
    end

    def after_clone
      @header_patterns=nil
      @body_patterns=nil

    end

    private
    def is_property_name?(p)
      p.each_char do |c|
        if c.match(/[_a-zA-Z0-9.]/).nil?
          return false
        end
      end
      true
    end
  end

end