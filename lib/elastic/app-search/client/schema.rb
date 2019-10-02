# Schema API - https://swiftype.com/documentation/app-search/api/schema
module Elastic
  module AppSearch
    class Client
      module Schema

        # Retrieve current schema for then engine.
        def get_schema(engine_name)
          get("engines/#{engine_name}/schema")
        end

        # Update schema for the current engine.
        def update_schema(engine_name, schema)
          post("engines/#{engine_name}/schema", schema)
        end

      end
    end
  end
end
