describe Elastic::AppSearch::Client::Analytics do
  include_context 'App Search Credentials'
  include_context 'Test Engine'

  let(:client) { Elastic::AppSearch::Client.new(client_options) }

  context '#get_top_clicks_analytics' do
    subject do
      client.get_top_clicks_analytics(
        engine_name,
        :query => 'cats',
        :page => {
          :size => 20,
        },
        :filters => {
          :date => {
            :from => Time.now.iso8601,
            :to => Time.now.iso8601
          }
        }
      )
    end

    it 'will query for analytics' do
      expect(subject['results']).to(eq([]))
    end
  end

  context '#get_top_queries_analytics' do
    subject do
      client.get_top_queries_analytics(
        engine_name,
        :page => {
          :size => 20
        },
        :filters => {
          :date => {
            :from => Time.now.iso8601,
            :to => Time.now.iso8601
          }
        }
      )
    end

    it 'will query for analytics' do
      expect(subject['results']).to(eq([]))
    end
  end

  context '#get_count_analytics' do
    let(:from) { Time.now.iso8601 }
    let(:to) { Time.now.iso8601 }

    subject do
      client.get_count_analytics(
        engine_name,
        :filters => {
          :all => [
            {
              :tag => ['mobile', 'web']
            }, {
              :query => 'cats'
            }, {
              :document_id => '163'
            }, {
              :date => {
                :from => from,
                :to => to
              }
            }
          ]
        },
        :interval => 'hour'
      )
    end

    it 'will query for analytics' do
      expect(subject['results'][0]['clicks']).to(eq(0))
      expect(subject['results'][0]['queries']).to(eq(0))
    end
  end
end
