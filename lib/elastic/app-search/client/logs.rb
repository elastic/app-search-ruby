# Logs API - https://swiftype.com/documentation/app-search/api/logs
module Elastic
  module AppSearch
    class Client
      module Logs

        # The API Log displays API request and response data at the Engine level.
        def get_api_logs(engine_name, options)
          post("engines/#{engine_name}/logs/api", options)
        end

      end
    end
  end
end
