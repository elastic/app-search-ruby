describe Elastic::AppSearch::Client::Documents do
  include_context 'App Search Credentials'
  include_context 'Static Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  context 'Documents' do
    describe '#list_documents' do
      context 'when no options are specified' do
        it 'will return all documents' do
          response = client.list_documents(engine_name)
          expect(response['results'].size).to(eq(2))
          expect(response['results'].map { |d| d['id'] }).to(include(document1['id'], document2['id']))
        end
      end

      context 'when options are specified' do
        it 'will return all documents' do
          response = client.list_documents(engine_name, :page => { :size => 1, :current => 2 })
          expect(response['results'].size).to(eq(1))
        end
      end
    end
  end
end
