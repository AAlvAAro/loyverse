RSpec.describe LoyverseApi::Endpoints::Items do
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

  describe "#get_item" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "id" => "item-123" }) }

    it "fetches a specific item by ID" do
      expect(connection).to receive(:get).with("items/item-123", {}).and_return(response)

      result = client.get_item("item-123")

      expect(result).to eq({ "id" => "item-123" })
    end
  end

  describe "#list_items" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "items" => [] }) }

    it "lists items with default parameters" do
      expect(connection).to receive(:get).with("items", { limit: 250 }).and_return(response)

      client.list_items
    end

    it "accepts custom limit" do
      expect(connection).to receive(:get).with("items", { limit: 100 }).and_return(response)

      client.list_items(limit: 100)
    end

    it "accepts cursor" do
      expect(connection).to receive(:get).with("items", { limit: 250, cursor: "cursor123" }).and_return(response)

      client.list_items(cursor: "cursor123")
    end

    it "accepts time filters" do
      expect(connection).to receive(:get).with("items", hash_including(:updated_at_min, :updated_at_max)).and_return(response)

      client.list_items(updated_at_min: "2024-01-01T00:00:00Z", updated_at_max: "2024-12-31T23:59:59Z")
    end
  end

  describe "#create_item" do
    let(:response) { instance_double(Faraday::Response, status: 201, body: { "id" => "new-item" }) }

    it "creates an item with minimal params" do
      expect(connection).to receive(:post).with("items", hash_including(item_name: "Test Item")).and_return(response)

      client.create_item(item_name: "Test Item")
    end

    it "creates an item with all params" do
      expect(connection).to receive(:post).with("items", hash_including(
        item_name: "Test Item",
        category_id: "cat-123",
        track_stock: true
      )).and_return(response)

      client.create_item(item_name: "Test Item", category_id: "cat-123", track_stock: true)
    end
  end

  describe "#update_item" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "id" => "item-123" }) }

    it "updates an item" do
      expect(connection).to receive(:put).with("items/item-123", { item_name: "Updated Name" }).and_return(response)

      client.update_item("item-123", item_name: "Updated Name")
    end
  end

  describe "#delete_item" do
    let(:response) { instance_double(Faraday::Response, status: 204, body: nil) }

    it "deletes an item" do
      expect(connection).to receive(:delete).with("items/item-123").and_return(response)

      client.delete_item("item-123")
    end
  end
end
