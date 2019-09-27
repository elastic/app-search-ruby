# Synonyms API - https://swiftype.com/documentation/app-search/api/analytics
module Elastic
  module AppSearch
    class Client
      module Credentials

        # Retrieve available credentials
        def list_credentials(current: 1, size: 20)
          get("credentials", :page => { :current => current, :size => size })
        end

        # Create a new credential
        def create_credential(options)
          post("credentials", options)
        end

        # Update an existing credential
        def update_credential(name, options)
          put("credentials/#{name}", options)
        end

        # Destroy an existing credential
        def destroy_credential(name)
          delete("credentials/#{name}")
        end

      end
    end
  end
end
