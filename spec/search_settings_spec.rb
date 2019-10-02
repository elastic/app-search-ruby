describe Elastic::AppSearch::Client::SearchSettings do
  include_context 'App Search Credentials'
  include_context 'Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  context 'SearchSettings' do
    let(:default_settings) do
      {
        'search_fields' => {
          'id' => {
            'weight' => 1
          }
        },
        'result_fields' => { 'id' => { 'raw' => {} } },
        'boosts' => {}
      }
    end

    let(:updated_settings) do
      {
        'search_fields' => {
          'id' => {
            'weight' => 3
          }
        },
        'result_fields' => { 'id' => { 'raw' => {} } },
        'boosts' => {}
      }
    end

    describe '#show_settings' do
      subject { client.show_settings(engine_name) }

      it 'should return default settings' do
        expect(subject).to(match(default_settings))
      end
    end

    describe '#update_settings' do
      subject { client.show_settings(engine_name) }

      before do
        client.update_settings(engine_name, updated_settings)
      end

      it 'should update search settings' do
        expect(subject).to(match(updated_settings))
      end
    end

    describe '#reset_settings' do
      subject { client.show_settings(engine_name) }

      before do
        client.update_settings(engine_name, updated_settings)
        client.reset_settings(engine_name)
      end

      it 'should reset search settings' do
        expect(subject).to(match(default_settings))
      end
    end
  end
end
