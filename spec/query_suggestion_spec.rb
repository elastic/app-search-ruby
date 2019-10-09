describe Elastic::AppSearch::Client::Search do
  include_context 'App Search Credentials'
  include_context 'Static Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  context 'QuerySuggest' do
    describe '#query_suggestion' do
      let(:query) { 'cat' }
      let(:options) { { :size => 3, :types => { :documents => { :fields => ['title'] } } } }

      context 'when options are provided' do
        subject { client.query_suggestion(engine_name, query, options) }

        it 'should request query suggestions' do
          expected = {
            'meta' => anything,
            'results' => anything
          }
          expect(subject).to(match(expected))
        end
      end

      context 'when options are omitted' do
        subject { client.query_suggestion(engine_name, query) }

        it 'should request query suggestions' do
          expected = {
            'meta' => anything,
            'results' => anything
          }
          expect(subject).to(match(expected))
        end
      end
    end
  end
end
