describe Elastic::AppSearch::ClientException do
  describe "when parsing a response body" do
    describe "and there is an 'errors' property on the response" do
      it 'will parse a single error message' do
        expect(Elastic::AppSearch::ClientException.new(
          { "errors" => [ "Unauthorized action." ] }
        ).message).to eq("Error: Unauthorized action.")
      end

      it 'will parse multiple error messages' do
        expect(Elastic::AppSearch::ClientException.new(
          { "errors" => [ "Unauthorized action.", "Service unavailable" ] }
        ).message).to eq("Errors: [\"Unauthorized action.\", \"Service unavailable\"]")
      end

      it 'will parse when there is a string instead of an array in errors' do
        expect(Elastic::AppSearch::ClientException.new(
          { "errors" => "Routing Error. The path you have requested is invalid." }
        ).message).to eq("Error: Routing Error. The path you have requested is invalid.")
      end
    end

    describe "when there is an array of responses" do
      it 'will parse a single error message' do
        expect(Elastic::AppSearch::ClientException.new(
          [
            { "errors" => [ "Unauthorized action." ] },
            { "errors" => [ "Service unavailable" ] }
          ]
        ).message).to eq("Errors: [\"Unauthorized action.\", \"Service unavailable\"]")
      end

      it 'will parse multiple error messages' do
        expect(Elastic::AppSearch::ClientException.new(
          [
            { "errors" => [ "Unauthorized action.", "Service unavailable" ] },
            { "errors" => [ "Another error" ] }
          ]
        ).message).to eq("Errors: [\"Unauthorized action.\", \"Service unavailable\", \"Another error\"]")
      end

      it 'will parse when there is a string instead of an array in errors' do
        expect(Elastic::AppSearch::ClientException.new(
          [
            { "errors" => [ "Unauthorized action.", "Service unavailable" ] },
            { "errors" => [ "Another error" ] },
            { "errors" => "Routing Error. The path you have requested is invalid." }
          ]
        ).message).to eq("Errors: [\"Unauthorized action.\", \"Service unavailable\", \"Another error\", \"Routing Error. The path you have requested is invalid.\"]")
      end
    end

    describe "and there is a single 'error'" do
      it 'will just return the entire response body' do
        expect(Elastic::AppSearch::ClientException.new(
          { "error" => "Unauthorized action." }
        ).message).to eq("Error: {\"error\"=>\"Unauthorized action.\"}")
      end
    end

    describe "and there is a just a string" do
      it 'will just return the entire response body' do
        expect(Elastic::AppSearch::ClientException.new(
          "Unauthorized action."
        ).message).to eq("Error: Unauthorized action.")
      end
    end
  end
end