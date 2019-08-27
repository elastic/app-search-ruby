module Elastic
  module AppSearch
    class ClientException < StandardError
      attr_reader :errors

      def extract_messages(response)
        if response['errors']
          if response['errors'].is_a?(Array)
           return response['errors']
          else
           return [response['errors']]
          end
        else
         return [response]
        end
      end

      def initialize(response)
        if response.is_a?(Array)
          @errors = response.flat_map { |r| extract_messages(r) }
        else
          @errors = extract_messages(response)
        end

        message = (errors.size == 1) ? "Error: #{errors.first}" : "Errors: #{errors.inspect}"
        super(message)
      end
    end

    class NonExistentRecord < ClientException; end
    class InvalidCredentials < ClientException; end
    class BadRequest < ClientException; end
    class Forbidden < ClientException; end
    class InvalidDocument < ClientException; end
    class RequestEntityTooLarge < ClientException; end

    class UnexpectedHTTPException < ClientException
      def initialize(response, response_json)
        errors = (response_json['errors'] || [response.message]).map { |e| "(#{response.code}) #{e}" }
        super({ 'errors' => errors })
      end
    end
  end
end
