require 'config_helper'
require 'securerandom'

describe Elastic::AppSearch::Client do
  include_context 'App Search Credentials'
  let(:client) { Elastic::AppSearch::Client.new(client_options) }

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
      decoded_token = JWT.decode(subject, key, true, :algorithm => 'HS256')
      expect(decoded_token[0]['api_key_name']).to(eq(api_key_name))
      expect(decoded_token[0]['query']).to(eq('cat'))
    end
  end

  describe 'Requests' do
    it 'should include client name and version in headers' do
      if (client_options[:api_endpoint])
        stub_request(:any, "#{client_options[:api_endpoint]}engines")
        client.list_engines
        expect(WebMock).to(
          have_requested(:get, "#{client_options[:api_endpoint]}engines")
          .with(
            :headers => {
              'X-Swiftype-Client' => 'elastic-app-search-ruby',
              'X-Swiftype-Client-Version' => Elastic::AppSearch::VERSION
            }
          )
        )
      else
        # CI runs against saas, so we keep this around for now. CI should be updated
        # to use slef-managed and we should drop support "host_identifier" this.
        stub_request(:any, "#{client_options[:host_identifier]}.api.swiftype.com/api/as/v1/engines")
        client.list_engines
        expect(WebMock).to(
          have_requested(:get, "https://#{client_options[:host_identifier]}.api.swiftype.com/api/as/v1/engines")
          .with(
            :headers => {
              'X-Swiftype-Client' => 'elastic-app-search-ruby',
              'X-Swiftype-Client-Version' => Elastic::AppSearch::VERSION
            }
          )
        )
      end
    end
  end

  context 'Configuration' do
    context 'host_identifier' do
      it 'sets the base url correctly' do
        client = Elastic::AppSearch::Client.new(:host_identifier => 'host-asdf', :api_key => 'foo')
        expect(client.api_endpoint).to(eq('https://host-asdf.api.swiftype.com/api/as/v1/'))
      end

      it 'sets the base url correctly using deprecated as_host_key' do
        client = Elastic::AppSearch::Client.new(:account_host_key => 'host-asdf', :api_key => 'foo')
        expect(client.api_endpoint).to(eq('https://host-asdf.api.swiftype.com/api/as/v1/'))
      end
    end
  end
end
