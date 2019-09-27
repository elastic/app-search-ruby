# Analytics API - https://swiftype.com/documentation/app-search/api/analytics
module Elastic
  module AppSearch
    class Client
      module Analytics

        # Returns the number of clicks received by a document in descending order.
        def getTopClicksAnalytics(engine_name, options)
          post("engines/#{engine_name}/analytics/clicks", options)
        end

        # Returns queries anlaytics by usage count
        def getTopQueriesAnalytics(engine_name, options)
          post("engines/#{engine_name}/analytics/queries", options)
        end

        # Returns the number of clicks and total number of queries over a period.
        def getCountAnalytics(engine_name, options)
          post("engines/#{engine_name}/analytics/counts", options)
        end

      end
    end
  end
end
