# Analytics API - https://swiftype.com/documentation/app-search/api/analytics
module Elastic
  module AppSearch
    class Client
      module Analytics

        # Returns the number of clicks received by a document in descending order.
        def get_top_clicks_analytics(engine_name, options)
          post("engines/#{engine_name}/analytics/clicks", options)
        end

        # Returns queries analytics by usage count
        def get_top_queries_analytics(engine_name, options)
          post("engines/#{engine_name}/analytics/queries", options)
        end

        # Returns the number of clicks and total number of queries over a period.
        def get_count_analytics(engine_name, options)
          post("engines/#{engine_name}/analytics/counts", options)
        end

      end
    end
  end
end
