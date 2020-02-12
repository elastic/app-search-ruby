module Elastic
  module AppSearch
    class Client
      module MetaEngines

        ENGINE_TYPE_META = 'meta'.freeze()

        def create_meta_engine(engine_name, source_engines)
          post('engines', :name => engine_name, :type => ENGINE_TYPE_META, :source_engines => source_engines)
        end

        def add_meta_engine_sources(engine_name, source_engines)
          post("engines/#{engine_name}/source_engines", source_engines)
        end

        def delete_meta_engine_sources(engine_name, source_engines)
          delete("engines/#{engine_name}/source_engines", source_engines)
        end

      end
    end
  end
end
