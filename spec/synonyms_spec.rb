describe Elastic::AppSearch::Client::Synonyms do
  include_context 'App Search Credentials'
  include_context 'Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  context '#create_synonym_set' do
    let(:synonyms) { ['park', 'trail'] }
    subject { client.create_synonym_set(engine_name, :synonyms => synonyms) }

    it 'will create a synonym' do
      expect(subject['id']).not_to(be_empty)
      expect(subject['synonyms']).to(eq(synonyms))
    end
  end

  context '#get_synonym_set' do
    let(:synonyms) { ['park', 'trail'] }
    let(:synonym_set_id) { client.create_synonym_set(engine_name, :synonyms => synonyms)['id'] }

    subject { client.get_synonym_set(engine_name, synonym_set_id) }

    it 'will retrieve a synonym set' do
      expect(subject['id']).to(eq(synonym_set_id))
      expect(subject['synonyms']).to(eq(synonyms))
    end
  end

  context '#update_synonym_set' do
    let(:synonyms) { ['park', 'trail'] }
    let(:updated_synonyms) { %w[park trail system] }
    let(:synonym_set_id) { client.create_synonym_set(engine_name, :synonyms => synonyms)['id'] }

    subject { client.update_synonym_set(engine_name, synonym_set_id, :synonyms => updated_synonyms) }

    it 'will update a synonym set' do
      expect(subject['id']).to(eq(synonym_set_id))
      expect(subject['synonyms']).to(eq(updated_synonyms))
    end
  end

  context '#list_synonym_sets' do
    subject { client.list_synonym_sets(engine_name, :current => 2, :size => 10) }

    it 'will list synonyms' do
      expect(subject['results']).to(eq([]))
    end

    it 'support paging params' do
      expect(subject['meta']['page']['current']).to(eq(2))
      expect(subject['meta']['page']['size']).to(eq(10))
    end
  end

  context '#destroy_synonym_set' do
    let(:synonyms) { ['park', 'trail'] }
    let(:synonym_set_id) { client.create_synonym_set(engine_name, :synonyms => synonyms)['id'] }

    subject { client.destroy_synonym_set(engine_name, synonym_set_id) }

    it 'will delete a synonym set' do
      expect(subject['deleted']).to(eq(true))
    end
  end
end
