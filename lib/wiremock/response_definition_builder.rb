module WireMock
  class ResponseDefinitionBuilder
    def initialize
      @status=200
    end

    def with_header(name, value)
      unless @headers
        @headers = {}
      end
      @headers[name] = value
      self
    end

    def with_headers(headers)
      headers.each { |key, value| with_header(key, value) }
      self
    end

    def with_status(status)
      @status = status
      self
    end
    def with_transformer(name)
      @transformer_names=[] unless @transformer_names
      @transformer_names.push(name)
      self
    end
    def with_transformer_parameter(name, value)
      @transformer_parameters={} unless @transformer_parameters
      @transformer_parameters[name]=value
      self
    end
    def proxied_from (url)
      @proxy_base_url=url
      self
    end

    def with_body(value)
      @body = value
      self
    end

    def build
      response = {}
      if @status
        response['status'] = @status;
      end
      if @body.is_a? String
        response['body'] = @body
      else
        if @body
          response['body'] = @body.to_json
        end
      end
      if @headers
        response['headers'] = @headers
      end
      if @proxy_base_url
        response['proxyBaseUrl'] = @proxy_base_url
      end
      if @transformer_names
        response['transformers'] = @transformer_names
      end
      if @transformer_parameters
        response['transformerParameters'] = @transformer_parameters
      end
      response
    end
  end

end