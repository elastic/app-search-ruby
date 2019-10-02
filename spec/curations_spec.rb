describe Elastic::AppSearch::Client::Curations do
  include_context 'App Search Credentials'
  include_context 'Static Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  let(:curation) do
    {
      'queries' => [
        'zion'
      ],
      'promoted' => [
        document1['id']
      ],
      'hidden' => [
        document2['id']
      ]
    }
  end
  let(:curation_id) { client.create_curation(engine_name, curation)['id'] }

  after(:each) do
    begin
      client.destroy_curation(engine_name, curation_id)
    rescue
      # Ignore it
    end
  end

  context '#create_curation' do
    it 'will create a curation' do
      expect(curation_id).not_to(be_empty)
    end
  end

  context '#get_curation' do
    subject { client.get_curation(engine_name, curation_id) }

    it 'will retrieve a curation' do
      expect(subject['queries']).to(eq(['zion']))
    end
  end

  context '#update_curation' do
    let(:updated_curation) do
      {
        'queries' => [
          'zion', 'lion'
        ],
        'promoted' => [
          document1['id']
        ]
      }
    end
    subject { client.update_curation(engine_name, curation_id, updated_curation) }

    it 'will update a curation' do
      expect(subject['id']).to(eq(curation_id))
    end
  end

  context '#list_curations' do
    subject { client.list_curations(engine_name, :current => 1, :size => 5) }

    it 'will list curations' do
      expect(subject['results']).to(eq([]))
    end

    it 'supports paging params' do
      expect(subject['meta']['page']['current']).to(eq(1))
      expect(subject['meta']['page']['size']).to(eq(5))
    end
  end

  context '#destroy_curation' do
    subject { client.destroy_curation(engine_name, curation_id) }

    it 'will destroy a curation' do
      expect(subject['deleted']).to(eq(true))
    end
  end
end
