RSpec.describe LoyverseApi::Endpoints::Modifiers do
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

  describe "#get_modifier" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "id" => "modifier-123" }) }

    it "fetches a specific modifier by ID" do
      expect(connection).to receive(:get).with("modifiers/modifier-123", {}).and_return(response)

      result = client.get_modifier("modifier-123")

      expect(result).to eq({ "id" => "modifier-123" })
    end
  end

  describe "#list_modifiers" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "modifiers" => [] }) }

    it "lists modifiers with default parameters" do
      expect(connection).to receive(:get).with("modifiers", { limit: 250 }).and_return(response)

      client.list_modifiers
    end

    it "accepts custom limit" do
      expect(connection).to receive(:get).with("modifiers", { limit: 100 }).and_return(response)

      client.list_modifiers(limit: 100)
    end

    it "accepts cursor" do
      expect(connection).to receive(:get).with("modifiers", { limit: 250, cursor: "cursor123" }).and_return(response)

      client.list_modifiers(cursor: "cursor123")
    end

    it "accepts time filters" do
      expect(connection).to receive(:get).with("modifiers", hash_including(:updated_at_min, :updated_at_max)).and_return(response)

      client.list_modifiers(updated_at_min: "2024-01-01T00:00:00Z", updated_at_max: "2024-12-31T23:59:59Z")
    end
  end

  describe "#create_modifier" do
    let(:response) { instance_double(Faraday::Response, status: 201, body: { "id" => "new-modifier" }) }

    it "creates a modifier with options" do
      expect(connection).to receive(:post).with("modifiers", {
        name: "Size",
        options: [
          { name: "Small", price: 0 },
          { name: "Large", price: 2.0 }
        ]
      }).and_return(response)

      client.create_modifier(
        name: "Size",
        options: [
          { name: "Small", price: 0 },
          { name: "Large", price: 2.0 }
        ]
      )
    end
  end

  describe "#delete_modifier" do
    let(:response) { instance_double(Faraday::Response, status: 204, body: nil) }

    it "deletes a modifier" do
      expect(connection).to receive(:delete).with("modifiers/modifier-123").and_return(response)

      client.delete_modifier("modifier-123")
    end
  end
end
