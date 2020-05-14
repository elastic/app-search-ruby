describe Elastic::AppSearch::Client::Documents do
  include_context 'App Search Credentials'
  include_context 'Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  context 'Documents' do
    let(:document) { { 'url' => 'http://www.youtube.com/watch?v=v1uyQZNg2vE' } }

    describe '#index_document' do
      subject { client.index_document(engine_name, document) }

      it 'should return a processed document status hash' do
        expect(subject).to(match('id' => anything))
      end

      context 'when the document has an id' do
        let(:id) { 'some_id' }
        let(:document) { { 'id' => id, 'url' => 'http://www.youtube.com/watch?v=v1uyQZNg2vE' } }

        it 'should return a processed document status hash with the same id' do
          expect(subject).to(eq('id' => id))
        end
      end

      context 'when a document has processing errors' do
        let(:document) { { 'id' => 'too long' * 100 } }

        it 'should raise an error when the API returns errors in the response' do
          expect do
            subject
          end.to(raise_error(Elastic::AppSearch::InvalidDocument, /Invalid field/))
        end
      end

      context 'when a document has a Ruby Time object' do
        let(:time_rfc3339) { '2018-01-01T01:01:01+00:00' }
        let(:time_object) { Time.parse(time_rfc3339) }
        let(:document) { { 'created_at' => time_object } }

        it 'should serialize the time object in RFC 3339' do
          response = subject
          expect(response).to(have_key('id'))
          document_id = response.fetch('id')
          expect do
            documents = client.get_documents(engine_name, [document_id])
            expect(documents.size).to(eq(1))
            expect(documents.first['created_at']).to(eq(time_rfc3339))
          end.to_not(raise_error)
        end
      end
    end

    describe '#index_documents' do
      let(:documents) { [document, second_document] }
      let(:second_document_id) { 'another_id' }
      let(:second_document) { { 'id' => second_document_id, 'url' => 'https://www.youtube.com/watch?v=9T1vfsHYiKY' } }
      subject { client.index_documents(engine_name, documents) }

      it 'should return an array of document status hashes' do
        expected = [
          { 'id' => anything, 'errors' => [] },
          { 'id' => second_document_id, 'errors' => [] }
        ]
        expect(subject).to(match(expected))
      end

      context 'when one of the documents has processing errors' do
        let(:second_document) { { 'id' => 'too long' * 100 } }

        it 'should return respective errors in an array of document processing hashes' do
          expected = [
            { 'id' => anything, 'errors' => [] },
            { 'id' => anything, 'errors' => ['Invalid field type: id must be less than 800 characters'] },
          ]
          expect(subject).to(match(expected))
        end
      end
    end

    describe '#update_documents' do
      let(:documents) { [document, second_document] }
      let(:second_document_id) { 'another_id' }
      let(:second_document) { { 'id' => second_document_id, 'url' => 'https://www.youtube.com/watch?v=9T1vfsHYiKY' } }
      let(:updates) do
        [
          {
            'id' => second_document_id,
            'url' => 'https://www.example.com'
          }
        ]
      end

      subject { client.update_documents(engine_name, updates) }

      before do
        client.index_documents(engine_name, documents)
      end

      # Note that since indexing a document takes up to a minute,
      # we don't expect this to succeed, so we simply verify that
      # the request responded with the correct 'id', even though
      # the 'errors' object likely contains errors.
      it 'should update existing documents' do
        expect(subject).to(match(['id' => second_document_id, 'errors' => anything]))
      end
    end

    describe '#get_documents' do
      let(:documents) { [first_document, second_document] }
      let(:first_document_id) { 'id' }
      let(:first_document) { { 'id' => first_document_id, 'url' => 'https://www.youtube.com/watch?v=v1uyQZNg2vE' } }
      let(:second_document_id) { 'another_id' }
      let(:second_document) { { 'id' => second_document_id, 'url' => 'https://www.youtube.com/watch?v=9T1vfsHYiKY' } }

      subject { client.get_documents(engine_name, [first_document_id, second_document_id]) }

      before do
        client.index_documents(engine_name, documents)
      end

      it 'will return documents by id' do
        response = subject
        expect(response.size).to(eq(2))
        expect(response[0]['id']).to(eq(first_document_id))
        expect(response[1]['id']).to(eq(second_document_id))
      end
    end
  end
end
