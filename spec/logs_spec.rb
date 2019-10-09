describe Elastic::AppSearch::Client::Logs do
  include_context 'App Search Credentials'
  include_context 'Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  context '#get_api_logs' do
    let(:from) { Time.now.iso8601 }
    let(:to) { Time.now.iso8601 }

    subject do
      options = {
        :filters => {
          :date => {
            :from => from,
            :to => to
          }
        },
        :page => {
          :total_results => 100,
          :size => 20
        },
        :query => 'search',
        :sort_direction => 'desc'
      }
      client.get_api_logs(engine_name, options)
    end

    it 'will retrieve api logs' do
      expect(subject['results']).to(eq([]))
    end
  end
end
