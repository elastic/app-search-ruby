describe Elastic::AppSearch::Client::Search do
  include_context 'App Search Credentials'
  include_context 'Static Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  context 'Search' do
    describe '#search' do
      subject { client.search(engine_name, query, options) }
      let(:query) { '' }
      let(:options) { { 'page' => { 'size' => 2 } } }

      it 'should execute a search query' do
        expected = {
          'meta' => anything,
          'results' => [anything, anything]
        }
        expect(subject).to(match(expected))
      end
    end

    describe '#multi_search' do
      subject { client.multi_search(engine_name, queries) }

      context 'when options are provided' do
        let(:queries) do
          [
            { 'query' => 'gatsby', 'options' => { 'page' => { 'size' => 1 } } },
            { 'query' => 'catcher', 'options' => { 'page' => { 'size' => 1 } } }
          ]
        end

        it 'should execute a multi search query' do
          response = subject
          expected = [
            {
              'meta' => anything,
              'results' => [{ 'id' => { 'raw' => '1' }, 'title' => anything, '_meta' => anything }]
            },
            {
              'meta' => anything,
              'results' => [{ 'id' => { 'raw' => '2' }, 'title' => anything, '_meta' => anything }]
            }
          ]
          expect(response).to(match(expected))
        end
      end

      context 'when options are omitted' do
        let(:queries) do
          [
            { 'query' => 'gatsby' },
            { 'query' => 'catcher' }
          ]
        end

        it 'should execute a multi search query' do
          response = subject
          expected = [
            {
              'meta' => anything,
              'results' => [{ 'id' => { 'raw' => '1' }, 'title' => anything, '_meta' => anything }]
            },
            {
              'meta' => anything,
              'results' => [{ 'id' => { 'raw' => '2' }, 'title' => anything, '_meta' => anything }]
            }
          ]

          expect(response).to(match(expected))
        end
      end

      context 'when a search is bad' do
        let(:queries) do
          [
            {
              'query' => 'cat',
              'options' => { 'search_fields' => { 'taco' => {} } }
            }, {
              'query' => 'dog',
              'options' => { 'search_fields' => { 'body' => {} } }
            }
          ]
        end

        it 'should throw an appropriate error' do
          expect { subject }.to(raise_error) do |e|
            expect(e).to(be_a(Elastic::AppSearch::BadRequest))
            expect(e.errors).to(eq(['Search fields contains invalid field: taco', 'Search fields contains invalid field: body']))
          end
        end
      end
    end
  end
end
