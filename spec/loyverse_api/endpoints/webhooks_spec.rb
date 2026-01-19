RSpec.describe LoyverseApi::Endpoints::Webhooks do
  let(:configuration) do
    config = LoyverseApi::Configuration.new
    config.access_token = "test_token"
    config
  end

  let(:client) { LoyverseApi::Client.new(configuration) }
  let(:connection) { instance_double(Faraday::Connection) }

  before do
    allow(client).to receive(:connection).and_return(connection)
  end

  describe "#get_webhook" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "id" => "webhook-123" }) }

    it "fetches a specific webhook by ID" do
      expect(connection).to receive(:get).with("webhooks/webhook-123", {}).and_return(response)

      result = client.get_webhook("webhook-123")

      expect(result).to eq({ "id" => "webhook-123" })
    end
  end

  describe "#list_webhooks" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "webhooks" => [] }) }

    it "lists webhooks with default parameters" do
      expect(connection).to receive(:get).with("webhooks", { limit: 250 }).and_return(response)

      client.list_webhooks
    end

    it "accepts custom limit" do
      expect(connection).to receive(:get).with("webhooks", { limit: 100 }).and_return(response)

      client.list_webhooks(limit: 100)
    end

    it "accepts cursor" do
      expect(connection).to receive(:get).with("webhooks", { limit: 250, cursor: "cursor123" }).and_return(response)

      client.list_webhooks(cursor: "cursor123")
    end
  end

  describe "#create_webhook" do
    let(:response) { instance_double(Faraday::Response, status: 201, body: { "id" => "new-webhook" }) }

    it "creates a webhook with required params" do
      expect(connection).to receive(:post).with("webhooks", {
        url: "https://example.com/webhook",
        event_types: ["ORDER_CREATED"]
      }).and_return(response)

      client.create_webhook(url: "https://example.com/webhook", event_types: ["ORDER_CREATED"])
    end

    it "creates a webhook with description" do
      expect(connection).to receive(:post).with("webhooks", {
        url: "https://example.com/webhook",
        event_types: ["ORDER_CREATED"],
        description: "My webhook"
      }).and_return(response)

      client.create_webhook(url: "https://example.com/webhook", event_types: ["ORDER_CREATED"], description: "My webhook")
    end

    it "converts single event_type to array" do
      expect(connection).to receive(:post).with("webhooks", {
        url: "https://example.com/webhook",
        event_types: ["ORDER_CREATED"]
      }).and_return(response)

      client.create_webhook(url: "https://example.com/webhook", event_types: "ORDER_CREATED")
    end
  end

  describe "#delete_webhook" do
    let(:response) { instance_double(Faraday::Response, status: 204, body: nil) }

    it "deletes a webhook" do
      expect(connection).to receive(:delete).with("webhooks/webhook-123").and_return(response)

      client.delete_webhook("webhook-123")
    end
  end

  describe "#verify_webhook_signature" do
    it "returns true for valid signature" do
      payload = '{"event":"test"}'
      secret = "my_secret"
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, payload)

      expect(client.verify_webhook_signature(payload, signature, secret)).to be true
    end

    it "returns false for invalid signature" do
      payload = '{"event":"test"}'
      secret = "my_secret"

      expect(client.verify_webhook_signature(payload, "invalid_signature", secret)).to be false
    end

    it "returns false when signature is nil" do
      expect(client.verify_webhook_signature("payload", nil, "secret")).to be false
    end

    it "returns false when payload is nil" do
      expect(client.verify_webhook_signature(nil, "signature", "secret")).to be false
    end
  end
end
