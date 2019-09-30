require 'config_helper'
require 'securerandom'

describe Elastic::AppSearch::Client do
  let(:engine_name) { "ruby-client-test-#{SecureRandom.hex}" }

  include_context 'App Search Credentials'
  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  before(:all) do
    # Bootstraps a static engine for 'read-only' options that require indexing
    # across the test suite
    @static_engine_name = "ruby-client-test-static-#{SecureRandom.hex}"
    as_api_key = ConfigHelper.get_as_api_key
    as_host_identifier = ConfigHelper.get_as_host_identifier
    as_api_endpoint = ConfigHelper.get_as_api_endpoint
    client_options = ConfigHelper.get_client_options(as_api_key, as_host_identifier, as_api_endpoint)
    @static_client = Elastic::AppSearch::Client.new(client_options)
    @static_client.create_engine(@static_engine_name)

    @document1 = { 'id' => '1', 'title' => 'The Great Gatsby' }
    @document2 = { 'id' => '2', 'title' => 'Catcher in the Rye' }
    @documents = [@document1, @document2]
    @static_client.index_documents(@static_engine_name, @documents)

    # Wait until documents are indexed
    start = Time.now
    ready = false
    until (ready)
      sleep(3)
      results = @static_client.search(@static_engine_name, '')
      ready = true if results['results'].length == 2
      ready = true if (Time.now - start).to_i >= 120 # Time out after 2 minutes
    end
  end

  after(:all) do
    @static_client.destroy_engine(@static_engine_name)
  end

  describe '#create_signed_search_key' do
    let(:key) { 'private-xxxxxxxxxxxxxxxxxxxx' }
    let(:api_key_name) { 'private-key' }
    let(:enforced_options) do
      {
        'query' => 'cat'
      }
    end

    subject do
      Elastic::AppSearch::Client.create_signed_search_key(key, api_key_name, enforced_options)
    end

    it 'should build a valid jwt' do
      decoded_token = JWT.decode subject, key, true, { algorithm: 'HS256' }
      expect(decoded_token[0]['api_key_name']).to eq(api_key_name)
      expect(decoded_token[0]['query']).to eq('cat')
    end
  end

  describe 'Requests' do
    it 'should include client name and version in headers' do
      stub_request(:any, "#{client_options[:host_identifier]}.api.swiftype.com/api/as/v1/engines")
      client.list_engines
      expect(WebMock).to have_requested(:get, "https://#{client_options[:host_identifier]}.api.swiftype.com/api/as/v1/engines")
        .with(
          :headers => {
            'X-Swiftype-Client' => 'elastic-app-search-ruby',
            'X-Swiftype-Client-Version' => Elastic::AppSearch::VERSION
          }
        )
    end
  end

  context 'Configuration' do
    context 'host_identifier' do
      it 'sets the base url correctly' do
        client = Elastic::AppSearch::Client.new(:host_identifier => 'host-asdf', :api_key => 'foo')
        expect(client.api_endpoint).to eq('https://host-asdf.api.swiftype.com/api/as/v1/')
      end

      it 'sets the base url correctly using deprecated as_host_key' do
        client = Elastic::AppSearch::Client.new(:account_host_key => 'host-asdf', :api_key => 'foo')
        expect(client.api_endpoint).to eq('https://host-asdf.api.swiftype.com/api/as/v1/')
      end
    end
  end
end
