describe Elastic::AppSearch::Client::Search do
  include_context 'App Search Credentials'
  include_context 'Static client'

  context 'QuerySuggest' do
    describe '#query_suggestion' do
      let(:query) { 'cat' }
      let(:options) { { :size => 3, :types => { :documents => { :fields => ['title'] } } } }

      context 'when options are provided' do
        subject { @static_client.query_suggestion(@static_engine_name, query, options) }

        it 'should request query suggestions' do
          expect(subject).to match(
            'meta' => anything,
            'results' => anything
          )
        end
      end

      context 'when options are omitted' do
        subject { @static_client.query_suggestion(@static_engine_name, query) }

        it 'should request query suggestions' do
          expect(subject).to match(
            'meta' => anything,
            'results' => anything
          )
        end
      end
    end
  end

end