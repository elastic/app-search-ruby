require 'set'
require 'elastic/app-search/request'
require 'elastic/app-search/utils'
require 'jwt'

module Elastic
  module AppSearch
    # API client for the {Elastic App Search API}[https://www.elastic.co/cloud/app-search-service].
    class Client
      autoload :Analytics, 'elastic/app-search/client/analytics'
      autoload :Click, 'elastic/app-search/client/click'
      autoload :Credentials, 'elastic/app-search/client/credentials'
      autoload :Curations, 'elastic/app-search/client/curations'
      autoload :Documents, 'elastic/app-search/client/documents'
      autoload :Engines, 'elastic/app-search/client/engines'
      autoload :MetaEngines, 'elastic/app-search/client/meta_engines'
      autoload :Logs, 'elastic/app-search/client/logs'
      autoload :Schema, 'elastic/app-search/client/schema'
      autoload :Search, 'elastic/app-search/client/search'
      autoload :SearchSettings, 'elastic/app-search/client/search_settings'
      autoload :Synonyms, 'elastic/app-search/client/synonyms'
      autoload :QuerySuggestion, 'elastic/app-search/client/query_suggestion'

      DEFAULT_TIMEOUT = 15

      include Elastic::AppSearch::Request

      attr_reader :api_key, :open_timeout, :overall_timeout, :api_endpoint

      # Create a new Elastic::AppSearch::Client client
      #
      # @param options [Hash] a hash of configuration options that will override what is set on the Elastic::AppSearch class.
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

      include Elastic::AppSearch::Client::Analytics
      include Elastic::AppSearch::Client::Click
      include Elastic::AppSearch::Client::Credentials
      include Elastic::AppSearch::Client::Curations
      include Elastic::AppSearch::Client::Documents
      include Elastic::AppSearch::Client::Engines
      include Elastic::AppSearch::Client::MetaEngines
      include Elastic::AppSearch::Client::Logs
      include Elastic::AppSearch::Client::Schema
      include Elastic::AppSearch::Client::Search
      include Elastic::AppSearch::Client::SearchSettings
      include Elastic::AppSearch::Client::SignedSearchOptions
      include Elastic::AppSearch::Client::Synonyms
      include Elastic::AppSearch::Client::QuerySuggestion
    end
  end
end
