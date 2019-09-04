module Elastic
  module AppSearch
    class ClientException < StandardError
      attr_reader :errors

      def extract_messages(response)
        errors_value = response['errors']
        return errors_value if errors_value && errors_value.is_a?(Array)
        return [errors_value] if errors_value && !errors_value.is_a?(Array)
        [response]
      end

      def initialize(response)
        @errors = response.is_a?(Array) ? response.flat_map { |r| extract_messages(r) } : extract_messages(response)
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
