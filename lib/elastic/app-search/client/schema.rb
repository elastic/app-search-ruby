# Schema API - https://swiftype.com/documentation/app-search/api/schema
module Elastic
  module AppSearch
    class Client
      module Schema

        # Retrieve schema for the current engine.
        def get_schema(engine_name)
          get("engines/#{engine_name}/schema")
        end

        # Create a new schema field or update existing schema for the current engine.
        def update_schema(engine_name, schema)
          post("engines/#{engine_name}/schema", schema)
        end

      end
    end
  end
end
