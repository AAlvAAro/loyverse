RSpec.describe LoyverseApi::Client do
  let(:configuration) do
    config = LoyverseApi::Configuration.new
    config.access_token = "test_token"
    config
  end

  let(:client) { described_class.new(configuration) }
  let(:connection) { instance_double(Faraday::Connection) }

  before do
    allow(client).to receive(:connection).and_return(connection)
  end

  describe "#initialize" do
    it "raises an error without access token" do
      config = LoyverseApi::Configuration.new
      expect { described_class.new(config) }.to raise_error(LoyverseApi::AuthenticationError)
    end

    it "includes mixin methods" do
      expect(client).to respond_to(:list_items)
      expect(client).to respond_to(:list_categories)
      expect(client).to respond_to(:list_inventory)
      expect(client).to respond_to(:list_receipts)
      expect(client).to respond_to(:list_webhooks)
      expect(client).to respond_to(:list_customers)
      expect(client).to respond_to(:list_discounts)
      expect(client).to respond_to(:list_employees)
      expect(client).to respond_to(:list_modifiers)
    end

    it "uses provided configuration" do
      custom_config = LoyverseApi::Configuration.new
      custom_config.access_token = "custom_token"
      custom_client = described_class.new(custom_config)

      expect(custom_client.configuration).to eq(custom_config)
    end

    it "uses global configuration when none provided" do
      LoyverseApi.configure do |config|
        config.access_token = "global_token"
      end

      global_client = described_class.new

      expect(global_client.configuration.access_token).to eq("global_token")
    end
  end

  describe "#connection" do
    it "creates a Faraday connection with correct settings" do
      allow(client).to receive(:connection).and_call_original
      connection = client.connection

      expect(connection).to be_a(Faraday::Connection)
      expect(connection.headers['Authorization']).to eq("Bearer test_token")
      expect(connection.headers['Content-Type']).to eq('application/json')
      expect(connection.headers['Accept']).to eq('application/json')
    end

    it "uses configuration timeout settings" do
      allow(client).to receive(:connection).and_call_original
      connection = client.connection

      expect(connection.options.timeout).to eq(30)
      expect(connection.options.open_timeout).to eq(10)
    end

    it "memoizes the connection" do
      allow(client).to receive(:connection).and_call_original
      conn1 = client.connection
      conn2 = client.connection

      expect(conn1).to equal(conn2)
    end
  end

  describe "#get" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "data" => "test" }) }

    it "makes a GET request" do
      expect(connection).to receive(:get).with("/test", { limit: 10 }).and_return(response)

      result = client.get("/test", params: { limit: 10 })

      expect(result).to eq({ "data" => "test" })
    end

    it "makes a GET request without params" do
      expect(connection).to receive(:get).with("/test", {}).and_return(response)

      client.get("/test")
    end
  end

  describe "#post" do
    let(:response) { instance_double(Faraday::Response, status: 201, body: { "id" => "123" }) }

    it "makes a POST request" do
      body = { name: "Test" }
      expect(connection).to receive(:post).with("/test", body).and_return(response)

      result = client.post("/test", body: body)

      expect(result).to eq({ "id" => "123" })
    end

    it "makes a POST request without body" do
      expect(connection).to receive(:post).with("/test", {}).and_return(response)

      client.post("/test")
    end
  end

  describe "#put" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "updated" => true }) }

    it "makes a PUT request" do
      body = { name: "Updated" }
      expect(connection).to receive(:put).with("/test", body).and_return(response)

      result = client.put("/test", body: body)

      expect(result).to eq({ "updated" => true })
    end
  end

  describe "#delete" do
    let(:response) { instance_double(Faraday::Response, status: 204, body: nil) }

    it "makes a DELETE request" do
      expect(connection).to receive(:delete).with("/test").and_return(response)

      result = client.delete("/test")

      expect(result).to be_nil
    end
  end

  describe "error handling" do
    describe "BadRequestError (400)" do
      let(:error_body) do
        {
          "error" => {
            "message" => "Invalid request",
            "code" => "BAD_REQUEST",
            "details" => { "field" => "email" }
          }
        }
      end
      let(:response) { instance_double(Faraday::Response, status: 400, body: error_body) }

      it "raises BadRequestError with message, code, and details" do
        expect(connection).to receive(:get).with("/test", {}).and_return(response)

        expect { client.get("/test") }.to raise_error(LoyverseApi::BadRequestError) do |error|
          expect(error.message).to eq("Invalid request")
          expect(error.code).to eq("BAD_REQUEST")
          expect(error.details).to eq({ "field" => "email" })
        end
      end

      it "handles alternative message format" do
        alt_body = { "message" => "Bad request" }
        alt_response = instance_double(Faraday::Response, status: 400, body: alt_body)
        expect(connection).to receive(:get).with("/test", {}).and_return(alt_response)

        expect { client.get("/test") }.to raise_error(LoyverseApi::BadRequestError, "Bad request")
      end
    end

    describe "AuthenticationError (401)" do
      let(:error_body) { { "error" => { "message" => "Invalid token" } } }
      let(:response) { instance_double(Faraday::Response, status: 401, body: error_body) }

      it "raises AuthenticationError" do
        expect(connection).to receive(:get).with("/test", {}).and_return(response)

        expect { client.get("/test") }.to raise_error(LoyverseApi::AuthenticationError, "Invalid token")
      end
    end

    describe "AuthorizationError (403)" do
      let(:error_body) { { "error" => { "message" => "Access denied" } } }
      let(:response) { instance_double(Faraday::Response, status: 403, body: error_body) }

      it "raises AuthorizationError" do
        expect(connection).to receive(:get).with("/test", {}).and_return(response)

        expect { client.get("/test") }.to raise_error(LoyverseApi::AuthorizationError, "Access denied")
      end
    end

    describe "NotFoundError (404)" do
      let(:error_body) { { "error" => { "message" => "Resource not found" } } }
      let(:response) { instance_double(Faraday::Response, status: 404, body: error_body) }

      it "raises NotFoundError" do
        expect(connection).to receive(:get).with("/test", {}).and_return(response)

        expect { client.get("/test") }.to raise_error(LoyverseApi::NotFoundError, "Resource not found")
      end
    end

    describe "RateLimitError (429)" do
      let(:error_body) { { "error" => { "message" => "Too many requests" } } }
      let(:response) { instance_double(Faraday::Response, status: 429, body: error_body) }

      it "raises RateLimitError" do
        expect(connection).to receive(:get).with("/test", {}).and_return(response)

        expect { client.get("/test") }.to raise_error(LoyverseApi::RateLimitError, "Too many requests")
      end

      it "uses default message when none provided" do
        empty_response = instance_double(Faraday::Response, status: 429, body: {})
        expect(connection).to receive(:get).with("/test", {}).and_return(empty_response)

        expect { client.get("/test") }.to raise_error(LoyverseApi::RateLimitError, "Rate limit exceeded")
      end
    end

    describe "ServerError (5xx)" do
      [500, 502, 503, 504].each do |status_code|
        it "raises ServerError for #{status_code}" do
          error_body = { "error" => { "message" => "Server error" } }
          response = instance_double(Faraday::Response, status: status_code, body: error_body)
          expect(connection).to receive(:get).with("/test", {}).and_return(response)

          expect { client.get("/test") }.to raise_error(LoyverseApi::ServerError, "Server error")
        end
      end

      it "uses default message when none provided" do
        empty_response = instance_double(Faraday::Response, status: 500, body: {})
        expect(connection).to receive(:get).with("/test", {}).and_return(empty_response)

        expect { client.get("/test") }.to raise_error(LoyverseApi::ServerError, "Server error occurred")
      end
    end

    describe "ApiError (unknown status)" do
      let(:response) { instance_double(Faraday::Response, status: 418, body: {}) }

      it "raises ApiError for unknown status codes" do
        expect(connection).to receive(:get).with("/test", {}).and_return(response)

        expect { client.get("/test") }.to raise_error(LoyverseApi::ApiError, "Unknown error occurred")
      end
    end

    describe "Faraday errors" do
      it "raises Error for timeout" do
        expect(connection).to receive(:get).and_raise(Faraday::TimeoutError)

        expect { client.get("/test") }.to raise_error(LoyverseApi::Error, "Request timeout")
      end

      it "raises Error for connection failure" do
        expect(connection).to receive(:get).and_raise(Faraday::ConnectionFailed)

        expect { client.get("/test") }.to raise_error(LoyverseApi::Error, "Connection failed")
      end
    end

    describe "error message extraction" do
      it "handles non-hash response body" do
        response = instance_double(Faraday::Response, status: 400, body: "Invalid")
        expect(connection).to receive(:get).with("/test", {}).and_return(response)

        expect { client.get("/test") }.to raise_error(LoyverseApi::BadRequestError)
      end

      it "handles missing error fields" do
        response = instance_double(Faraday::Response, status: 400, body: {})
        expect(connection).to receive(:get).with("/test", {}).and_return(response)

        expect { client.get("/test") }.to raise_error(LoyverseApi::BadRequestError) do |error|
          expect(error.code).to be_nil
          expect(error.details).to be_nil
        end
      end
    end
  end

  describe "successful responses" do
    it "returns body for 200 status" do
      response = instance_double(Faraday::Response, status: 200, body: { "data" => "success" })
      expect(connection).to receive(:get).with("/test", {}).and_return(response)

      result = client.get("/test")

      expect(result).to eq({ "data" => "success" })
    end

    it "returns body for 201 status" do
      response = instance_double(Faraday::Response, status: 201, body: { "created" => true })
      expect(connection).to receive(:post).with("/test", {}).and_return(response)

      result = client.post("/test")

      expect(result).to eq({ "created" => true })
    end

    it "returns body for 204 status" do
      response = instance_double(Faraday::Response, status: 204, body: nil)
      expect(connection).to receive(:delete).with("/test").and_return(response)

      result = client.delete("/test")

      expect(result).to be_nil
    end
  end
end
