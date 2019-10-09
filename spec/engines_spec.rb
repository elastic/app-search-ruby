describe Elastic::AppSearch::Client::Engines do
  include_context 'App Search Credentials'
  include_context 'Engine Name'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  context 'Engines' do
    after do
      client.destroy_engine(engine_name) rescue Elastic::AppSearch::NonExistentRecord
    end

    context '#create_engine' do
      it 'should create an engine when given a right set of parameters' do
        expect { client.get_engine(engine_name) }.to(raise_error(Elastic::AppSearch::NonExistentRecord))
        client.create_engine(engine_name)
        expect { client.get_engine(engine_name) }.to_not(raise_error)
      end

      it 'should accept an optional language parameter' do
        expect { client.get_engine(engine_name) }.to(raise_error(Elastic::AppSearch::NonExistentRecord))
        client.create_engine(engine_name, 'da')
        expect(client.get_engine(engine_name)).to(match('name' => anything, 'type' => anything, 'language' => 'da'))
      end

      it 'should return an engine object' do
        engine = client.create_engine(engine_name)
        expect(engine).to(be_kind_of(Hash))
        expect(engine['name']).to(eq(engine_name))
      end

      it 'should return an error when the engine name has already been taken' do
        client.create_engine(engine_name)
        expect { client.create_engine(engine_name) }.to(raise_error) do |e|
          expect(e).to(be_a(Elastic::AppSearch::BadRequest))
          expect(e.errors).to(eq(['Name is already taken']))
        end
      end
    end

    context '#list_engines' do
      it 'should return an array with a list of engines' do
        expect(client.list_engines['results']).to(be_an(Array))
      end

      it 'should include the engine name in listed objects' do
        client.create_engine(engine_name)

        engines = client.list_engines['results']
        expect(engines.find { |e| e['name'] == engine_name }).to_not(be_nil)
      end

      it 'should include the engine name in listed objects with pagination' do
        client.create_engine(engine_name)

        engines = client.list_engines(:current => 1, :size => 20)['results']
        expect(engines.find { |e| e['name'] == engine_name }).to_not(be_nil)
      end
    end

    context '#destroy_engine' do
      it 'should destroy the engine if it exists' do
        client.create_engine(engine_name)
        expect { client.get_engine(engine_name) }.to_not(raise_error)

        client.destroy_engine(engine_name)
        expect { client.get_engine(engine_name) }.to(raise_error(Elastic::AppSearch::NonExistentRecord))
      end

      it 'should raise an error if the engine does not exist' do
        expect { client.destroy_engine(engine_name) }.to(raise_error(Elastic::AppSearch::NonExistentRecord))
      end
    end
  end
end
