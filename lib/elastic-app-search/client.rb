require 'set'
require 'elastic-app-search/request'
require 'elastic-app-search/utils'
require 'jwt'

module ElasticAppSearch
  # API client for the {Elastic App Search API}[https://www.elastic.co/cloud/app-search-service].
  class Client
    autoload :Documents, 'elastic-app-search/client/documents'
    autoload :Engines, 'elastic-app-search/client/engines'
    autoload :Search, 'elastic-app-search/client/search'
    autoload :QuerySuggestion, 'elastic-app-search/client/query_suggestion'
    autoload :SearchSettings, 'elastic-app-search/client/search_settings'

    DEFAULT_TIMEOUT = 15

    include ElasticAppSearch::Request

    attr_reader :api_key, :open_timeout, :overall_timeout, :api_endpoint

    # Create a new ElasticAppSearch::Client client
    #
    # @param options [Hash] a hash of configuration options that will override what is set on the ElasticAppSearch class.
    # @option options [String] :account_host_key or :host_identifier is your Host Identifier to use with this client.
    # @option options [String] :api_key can be any of your API Keys. Each has a different scope, so ensure you are using the correct key.
    # @option options [Numeric] :overall_timeout overall timeout for requests in seconds (default: 15s)
    # @option options [Numeric] :open_timeout the number of seconds Net::HTTP (default: 15s)
    #   will wait while opening a connection before raising a Timeout::Error
    def initialize(options = {})
      @api_endpoint = options.fetch(:api_endpoint) { "https://#{options.fetch(:account_host_key) { options.fetch(:host_identifier) }}.api.swiftype.com/api/as/v1/" }
      @api_key = options.fetch(:api_key)
      @open_timeout = options.fetch(:open_timeout, DEFAULT_TIMEOUT).to_f
      @overall_timeout = options.fetch(:overall_timeout, DEFAULT_TIMEOUT).to_f
    end

    module SignedSearchOptions
      ALGORITHM = 'HS256'.freeze

      module ClassMethods
        # Build a JWT for authentication
        #
        # @param [String] api_key the API Key to sign the request with
        # @param [String] api_key_name the unique name for the API Key
        # @option options see the {App Search API}[https://swiftype.com/documentation/app-search/] for supported search options.
        #
        # @return [String] the JWT to use for authentication
        def create_signed_search_key(api_key, api_key_name, options = {})
          payload = Utils.symbolize_keys(options).merge(:api_key_name => api_key_name)
          JWT.encode(payload, api_key, ALGORITHM)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end

    include ElasticAppSearch::Client::Documents
    include ElasticAppSearch::Client::Engines
    include ElasticAppSearch::Client::Search
    include ElasticAppSearch::Client::SignedSearchOptions
    include ElasticAppSearch::Client::QuerySuggestion
    include ElasticAppSearch::Client::SearchSettings
  end
end
