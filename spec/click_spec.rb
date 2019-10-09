describe Elastic::AppSearch::Client::Click do
  include_context 'App Search Credentials'
  include_context 'Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  context '#log_click_through' do
    let(:documents) { [first_document, second_document] }
    let(:first_document_id) { 'id' }
    let(:first_document) { { 'id' => first_document_id } }
    let(:second_document_id) { 'another_id' }
    let(:second_document) { { 'id' => second_document_id } }

    before { client.index_documents(engine_name, documents) }

    subject do
      client.log_click_through(
        engine_name,
        :query => 'cat videos',
        :document_id => first_document_id,
        :request_id => 'e4c4dea0bd7ad3d2f676575ef16dc7d2',
        :tags => ['firefox', 'web browser']
      )
    end

    it 'will log a click' do
      expect(subject[0]['id']).not_to(be_empty)
    end
  end
end
