# Curations API - https://swiftype.com/documentation/app-search/api/curations
module Elastic
  module AppSearch
    class Client
      module Curations

        # Retrieve available curations for the engine.
        def list_curations(engine_name, current: 1, size: 20)
          get("engines/#{engine_name}/curations", :page => { :current => current, :size => size })
        end

        # Create a new curation.
        def create_curation(engine_name, options)
          post("engines/#{engine_name}/curations", options)
        end

        # Retrieve a curation by id.
        def get_curation(engine_name, id)
          get("engines/#{engine_name}/curations/#{id}")
        end

        # Update an existing curation.
        def update_curation(engine_name, id, options)
          put("engines/#{engine_name}/curations/#{id}", options)
        end

        # Delete a curation by id.
        def destroy_curation(engine_name, id)
          delete("engines/#{engine_name}/curations/#{id}")
        end

      end
    end
  end
end
