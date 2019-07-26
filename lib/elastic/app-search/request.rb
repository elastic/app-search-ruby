require 'net/https'
require 'json'
require 'time'
require 'elastic/app-search/exceptions'
require 'elastic/app-search/version'
require 'openssl'

module Elastic
  module AppSearch
    CLIENT_NAME = 'elastic-app-search-ruby'
    CLIENT_VERSION = Elastic::AppSearch::VERSION

    module Request
      attr_accessor :last_request

      def get(path, params={})
        request(:get, path, params)
      end

      def post(path, params={})
        request(:post, path, params)
      end

      def put(path, params={})
        request(:put, path, params)
      end

      def patch(path, params={})
        request(:patch, path, params)
      end

      def delete(path, params={})
        request(:delete, path, params)
      end

      # Construct and send a request to the API.
      #
      # @raise [Timeout::Error] when the timeout expires
      def request(method, path, params = {})
        Timeout.timeout(overall_timeout) do
          uri = URI.parse("#{api_endpoint}#{path}")

          request = build_request(method, uri, params)
          http = Net::HTTP.new(uri.host, uri.port)
          http.open_timeout = open_timeout
          http.read_timeout = overall_timeout

          http.set_debug_output(STDERR) if debug?

          if uri.scheme == 'https'
            http.use_ssl = true
            # st_ssl_verify_none provides a means to disable SSL verification for debugging purposes. An example
            # is Charles, which uses a self-signed certificate in order to inspect https traffic. This will
            # not be part of this client's public API, this is more of a development enablement option
            http.verify_mode = ENV['st_ssl_verify_none'] == 'true' ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
            http.ca_file = File.join(File.dirname(__FILE__), '../..', 'data', 'ca-bundle.crt')
            http.ssl_timeout = open_timeout
          end

          @last_request = request

          response = http.request(request)
          response_json = parse_response(response)

          case response
          when Net::HTTPSuccess
            return response_json
          when Net::HTTPBadRequest
            raise Elastic::AppSearch::BadRequest, response_json
          when Net::HTTPUnauthorized
            raise Elastic::AppSearch::InvalidCredentials, response_json
          when Net::HTTPNotFound
            raise Elastic::AppSearch::NonExistentRecord, response_json
          when Net::HTTPForbidden
            raise Elastic::AppSearch::Forbidden, response_json
          when Net::HTTPRequestEntityTooLarge
            raise Elastic::AppSearch::RequestEntityTooLarge, response_json
          else
            raise Elastic::AppSearch::UnexpectedHTTPException.new(response, response_json)
          end
        end
      end

      private

      def parse_response(response)
        body = response.body.to_s.strip
        body == '' ? {} : JSON.parse(body)
      end

      def debug?
        @debug ||= (ENV['AS_DEBUG'] == 'true')
      end

      def serialize_json(object)
        JSON.generate(clean_json(object))
      end

      def clean_json(object)
        case object
        when Hash
          object.inject({}) do |builder, (key, value)|
            builder[key] = clean_json(value)
            builder
          end
        when Enumerable
          object.map { |value| clean_json(value) }
        else
          clean_atom(object)
        end
      end

      def clean_atom(atom)
        if atom.is_a?(Time)
          atom.to_datetime
        else
          atom
        end
      end

      def build_request(method, uri, params)
        klass = case method
                when :get
                  Net::HTTP::Get
                when :post
                  Net::HTTP::Post
                when :put
                  Net::HTTP::Put
                when :patch
                  Net::HTTP::Patch
                when :delete
                  Net::HTTP::Delete
                end

        req = klass.new(uri.request_uri)
        req.body = serialize_json(params) unless params.length == 0

        req['X-Swiftype-Client'] = CLIENT_NAME
        req['X-Swiftype-Client-Version'] = CLIENT_VERSION
        req['Content-Type'] = 'application/json'
        req['Authorization'] = "Bearer #{api_key}"

        req
      end
    end
  end
end
