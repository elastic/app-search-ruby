# Click API - https://swiftype.com/documentation/app-search/api/clickthrough
module Elastic
  module AppSearch
    class Client
      module Click

        # Send data about clicked results.
        def logClickthrough(engine_name, options)
          post("engines/#{engine_name}/documents", options)
        end

      end
    end
  end
end
