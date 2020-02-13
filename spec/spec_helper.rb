require 'bundler/setup'
require 'rspec'
require 'webmock/rspec'
require 'awesome_print'
require 'elastic/app-search'
require 'config_helper'
require 'securerandom'

WebMock.allow_net_connect!

#
# Uses a static engine that will not change between tests. It comes preloaded
# with documents that *are already indexed*. This means tests can run operations
# that require documents to be indexed, like "search".
#
# This is optimal for tests that perform read-only operations, like "search".
#
RSpec.shared_context 'Static Test Engine' do
  before(:all) do
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

  let(:engine_name) { @static_engine_name }
  let(:document1) { @document1 }
  let(:document2) { @document2 }

  after(:all) do
    @static_client.destroy_engine(@static_engine_name)
  end
end

RSpec.shared_context 'Engine Name' do
  let(:engine_name) { "ruby-client-test-#{SecureRandom.hex}" }
end

RSpec.shared_context 'Meta Engine Name' do
  let(:meta_engine_name) { "ruby-client-test-#{SecureRandom.hex}" }
end

RSpec.shared_context 'Test Engine' do
  let(:engine_name) { "ruby-client-test-#{SecureRandom.hex}" }

  before(:each) do
    client.create_engine(engine_name) rescue Elastic::AppSearch::BadRequest
  end

  after(:each) do
    client.destroy_engine(engine_name) rescue Elastic::AppSearch::NonExistentRecord
  end
end

RSpec.shared_context 'App Search Credentials' do
  let(:as_api_key) { ConfigHelper.get_as_api_key }
  # AS_ACCOUNT_HOST_KEY is deprecated
  let(:as_host_identifier) { ConfigHelper.get_as_host_identifier }
  let(:as_api_endpoint) { ConfigHelper.get_as_api_endpoint }
  let(:client_options) do
    ConfigHelper.get_client_options(as_api_key, as_host_identifier, as_api_endpoint)
  end
end

RSpec.shared_context 'App Search Admin Credentials' do
  let(:as_api_key) { ConfigHelper.get_as_admin_key }
  # AS_ACCOUNT_HOST_KEY is deprecated
  let(:as_host_identifier) { ConfigHelper.get_as_host_identifier }
  let(:as_api_endpoint) { ConfigHelper.get_as_api_endpoint }
  let(:client_options) do
    ConfigHelper.get_client_options(as_api_key, as_host_identifier, as_api_endpoint)
  end
end

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
