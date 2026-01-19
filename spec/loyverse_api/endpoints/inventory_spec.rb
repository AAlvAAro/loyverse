RSpec.describe LoyverseApi::Endpoints::Inventory do
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

  describe "#list_inventory" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "inventory_levels" => [] }) }

    it "lists inventory with default parameters" do
      expect(connection).to receive(:get).with("inventory", { limit: 250 }).and_return(response)

      client.list_inventory
    end

    it "accepts cursor for pagination" do
      expect(connection).to receive(:get).with("inventory", { limit: 250, cursor: "cursor123" }).and_return(response)

      client.list_inventory(cursor: "cursor123")
    end

    it "accepts variant_id filter" do
      expect(connection).to receive(:get).with("inventory", { limit: 250, variant_id: "var-123" }).and_return(response)

      client.list_inventory(variant_id: "var-123")
    end

    it "accepts store_id filter" do
      expect(connection).to receive(:get).with("inventory", { limit: 250, store_id: "store-123" }).and_return(response)

      client.list_inventory(store_id: "store-123")
    end

    it "accepts multiple filters" do
      expect(connection).to receive(:get).with("inventory", hash_including(
        limit: 250,
        variant_id: "var-123",
        store_id: "store-123"
      )).and_return(response)

      client.list_inventory(variant_id: "var-123", store_id: "store-123")
    end
  end

  describe "#update_inventory" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "in_stock" => 100 }) }

    it "updates inventory level" do
      expect(connection).to receive(:put).with("inventory", {
        variant_id: "var-123",
        store_id: "store-123",
        in_stock: 100
      }).and_return(response)

      client.update_inventory(variant_id: "var-123", store_id: "store-123", in_stock: 100)
    end

    it "accepts zero stock" do
      expect(connection).to receive(:put).with("inventory", {
        variant_id: "var-123",
        store_id: "store-123",
        in_stock: 0
      }).and_return(response)

      client.update_inventory(variant_id: "var-123", store_id: "store-123", in_stock: 0)
    end
  end
end
