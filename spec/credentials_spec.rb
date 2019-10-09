require 'securerandom'

describe Elastic::AppSearch::Client::Credentials do
  include_context 'App Search Admin Credentials'
  include_context 'Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }
  let(:key_name) { "spec-key-#{SecureRandom.hex}" }
  let(:api_key) do
    {
      :name => key_name,
      :type => 'private',
      :read => true,
      :write => false,
      :access_all_engines => false,
      :engines => [
        engine_name
      ]
    }
  end

  context '#create_credential' do
    after { client.destroy_credential(key_name) }
    subject { client.create_credential(api_key) }

    it 'will create an API Key' do
      expect(subject['name']).to(eq(key_name))
    end
  end

  context '#get_credential' do
    after { client.destroy_credential(key_name) }
    before { client.create_credential(api_key) }
    subject { client.get_credential(key_name) }

    it 'will retrieve an API Key' do
      expect(subject['name']).to(eq(key_name))
    end
  end

  context '#update_credential' do
    let(:updated_api_key) do
      api_key['write'] = true
      api_key
    end

    before { client.create_credential(api_key) }
    after { client.destroy_credential(key_name) }
    subject { client.update_credential(key_name, updated_api_key) }

    it 'will update an API Key' do
      expect(subject['name']).to(eq(key_name))
      expect(subject['write']).to(eq(true))
    end
  end

  context '#list_credentials' do
    before { client.create_credential(api_key) }
    after { client.destroy_credential(key_name) }
    subject { client.list_credentials }

    it 'will list all API Keys' do
      expect(subject['results'].map { |r| r['name'] }.include?(key_name)).to(eq(true))
    end
  end

  context '#destroy_credential' do
    before { client.create_credential(api_key) }
    subject { client.destroy_credential(key_name) }

    it 'will delete an API Key' do
      expect(subject['deleted']).to(eq(true))
    end
  end
end
