describe Elastic::AppSearch::Client::Schema do
  include_context 'App Search Credentials'
  include_context 'Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  context '#get_schema' do
    before { client.update_schema(engine_name, 'title' => 'text') }
    subject { client.get_schema(engine_name) }

    it 'will retrieve a schema' do
      expect(subject).to(eq('title' => 'text'))
    end
  end

  context '#update_schema' do
    subject { client.update_schema(engine_name, 'square_km' => 'number') }

    it 'will update a schema' do
      expect(subject).to(eq('square_km' => 'number'))
    end
  end
end
