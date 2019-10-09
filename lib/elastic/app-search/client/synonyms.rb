# Synonyms API - https://swiftype.com/documentation/app-search/api/synonyms
module Elastic
  module AppSearch
    class Client
      module Synonyms

        # Retrieve available synonym sets for the engine.
        def list_synonym_sets(engine_name, current: 1, size: 20)
          get("engines/#{engine_name}/synonyms", :page => { :current => current, :size => size })
        end

        # Retrieve a synonym set by id
        def get_synonym_set(engine_name, id)
          get("engines/#{engine_name}/synonyms/#{id}")
        end

        # Create a new synonym set
        def create_synonym_set(engine_name, synonyms)
          post("engines/#{engine_name}/synonyms", :synonyms => synonyms)
        end

        # Update an existing synonym set
        def update_synonym_set(engine_name, id, synonyms)
          put("engines/#{engine_name}/synonyms/#{id}", :synonyms => synonyms)
        end

        # Delete a synonym set by id
        def destroy_synonym_set(engine_name, id)
          delete("engines/#{engine_name}/synonyms/#{id}")
        end

      end
    end
  end
end
