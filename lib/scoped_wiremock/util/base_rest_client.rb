require 'json'
require 'httpclient/http'
require 'rest-client'
module ScopedWireMock
  module Util
    class BaseRestClient
      @@status_map={
          :post => HTTP::Status::CREATED,
          :delete => HTTP::Status::NO_CONTENT,
          :put => HTTP::Status::OK,
          :get => HTTP::Status::OK
      }
      attr_reader :base_url

      def initialize(base_url)
        @base_url = base_url
      end

      def execute_relative(uri_template, method, payload=nil, headers={}, params={})
        puts('Executing: ' + @base_url + uri_template + ' ' + method.to_s)
        execute(@base_url + uri_template, method, payload, headers, params)
      end

      def execute(url, method, payload=nil, headers={}, params={})
        self.lap 'Executing ' + url
        headers['Content-Type']= 'application/json' if payload
        headers['params']=params
        # Kernel::puts(url)
        response=RestClient::Request.execute(method: method, payload: payload.to_json, url: url, headers: headers)
        # response = make_http_request({:method => method, :uri => url, :body => payload.to_json, :header => headers})

        if valid_response_code?(method, response) and response.body and response.body.length>=2
          result = JSON.parse(response.body)
        else
          Kernel::puts response.body
          result = nil
        end
        self.lap_done
        result
      end

      def wait_for_service(seconds, ping_url=nil)
        ping_url=@base_url + '/Ping' if ping_url.nil?
        Kernel::warn("Waiting for supporting services to become available at #{ping_url}")
        start = Time.now
        pause_time=1
        result_code=500
        until result_code == 200
          sleep (pause_time)
          begin
            result = RestClient.get(ping_url)
            result_code = result.code
            if result_code != 200
              Kernel::warn("#{ping_url} responded with HTTP code #{result_code}")
            end
          rescue StandardError => e
            Kernel::warn("#{ping_url} responded with HTTP code #{e}")
            if Time.now-start > seconds
              raise StandardError, "Could not connect to the service within #{seconds} seconds"
            else
              result_code = 500
            end
          end
        end
      end

      def valid_response_code?(method, response)
        method==:post or response.code == @@status_map[method] #because people seem to return anything from post
      end

      def lap (next_step)
        lap_done
        @current_step_name=next_step
        @current_step_start=Time.now
        Kernel::puts("Now commencing task: '" + @current_step_name + "'")
      end

      def lap_done ()
        unless @current_step_name.nil?
          Kernel::puts("Task '" + @current_step_name + "' took " + (Time.now - @current_step_start).to_s)
        end
        @current_step_name = nil
      end
    end
  end

end