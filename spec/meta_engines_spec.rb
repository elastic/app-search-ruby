describe Elastic::AppSearch::Client::MetaEngines do
  include_context 'App Search Credentials'
  include_context 'Engine Name'
  include_context 'Meta Engine Name'
  include_context 'Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }
  let(:source_engines) { [engine_name] }

  # CI currently runs against SaaS. This feature is a Self-Managed only feature.
  context 'Meta Engines', :skip => "Unable to test Self-Managed features in CI." do

    after do
      client.destroy_engine(meta_engine_name) rescue Elastic::AppSearch::NonExistentRecord
    end

    context '#create_meta_engine' do
      it 'should create a meta engine when given a right set of parameters' do
        expect { client.get_engine(meta_engine_name) }.to raise_error(Elastic::AppSearch::NonExistentRecord)
        client.create_meta_engine(meta_engine_name, source_engines)
        expect { client.get_engine(meta_engine_name) }.to_not raise_error
      end

      it 'should return a meta engine object' do
        engine = client.create_meta_engine(meta_engine_name, source_engines)
        expect(engine).to be_kind_of(Hash)
        expect(engine['name']).to eq(meta_engine_name)
        expect(engine['type']).to eq('meta')
        expect(engine['source_engines']).to eq(source_engines)
      end

      it 'should return an error when the engine source engine is empty' do
        expect { client.create_meta_engine(engine_name, []) }.to(raise_error) do |e|
          expect(e).to be_a(Elastic::AppSearch::BadRequest)
          expect(e.errors).to eq(['Source engines are required for meta engines'])
        end
      end
    end

    context '#add_meta_engine_sources' do
      before do
        client.create_meta_engine(meta_engine_name, source_engines)
        client.delete_meta_engine_sources(meta_engine_name, source_engines)
      end

      it 'should add the source engine' do
        expect { client.add_meta_engine_sources(meta_engine_name, source_engines) }.to_not raise_error do |engine|
          expect(engine).to be_kind_of(Hash)
          expect(engine['name']).to eq(meta_engine_name)
          expect(engine['type']).to eq('meta')
          expect(engine['source_engines']).to be_kind_of(Array)
          expect(engine['source_engines']).to eq(source_engines)
        end
      end
    end

    context '#delete_meta_engine_sources' do
      before do
        client.create_meta_engine(meta_engine_name, source_engines)
      end

      it 'should remove the source engine' do
        expect { client.delete_meta_engine_sources(meta_engine_name, source_engines) }.to_not raise_error do |engine|
          expect(engine).to be_kind_of(Hash)
          expect(engine['name']).to eq(meta_engine_name)
          expect(engine['type']).to eq('meta')
          expect(engine['source_engines']).to be_kind_of(Array)
          expect(engine['source_engines']).to be_empty
        end
      end
    end
  end
end
