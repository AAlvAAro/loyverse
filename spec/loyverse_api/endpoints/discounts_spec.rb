RSpec.describe LoyverseApi::Endpoints::Discounts do
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

  describe "#get_discount" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "id" => "discount-123" }) }

    it "fetches a specific discount by ID" do
      expect(connection).to receive(:get).with("discounts/discount-123", {}).and_return(response)

      result = client.get_discount("discount-123")

      expect(result).to eq({ "id" => "discount-123" })
    end
  end

  describe "#list_discounts" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "discounts" => [] }) }

    it "lists discounts with default parameters" do
      expect(connection).to receive(:get).with("discounts", { limit: 250 }).and_return(response)

      client.list_discounts
    end

    it "accepts custom limit" do
      expect(connection).to receive(:get).with("discounts", { limit: 100 }).and_return(response)

      client.list_discounts(limit: 100)
    end

    it "accepts cursor" do
      expect(connection).to receive(:get).with("discounts", { limit: 250, cursor: "cursor123" }).and_return(response)

      client.list_discounts(cursor: "cursor123")
    end

    it "accepts time filters" do
      expect(connection).to receive(:get).with("discounts", hash_including(:updated_at_min, :updated_at_max)).and_return(response)

      client.list_discounts(updated_at_min: "2024-01-01T00:00:00Z", updated_at_max: "2024-12-31T23:59:59Z")
    end
  end

  describe "#create_discount" do
    let(:response) { instance_double(Faraday::Response, status: 201, body: { "id" => "new-discount" }) }

    it "creates a discount with minimal params" do
      expect(connection).to receive(:post).with("discounts", {
        name: "10% Off",
        type: "FIXED_PERCENT",
        discount_amount: 10.0,
        applies_to: "RECEIPT",
        enabled: true
      }).and_return(response)

      client.create_discount(name: "10% Off", type: "FIXED_PERCENT", discount_amount: 10.0)
    end

    it "creates a discount with all params" do
      expect(connection).to receive(:post).with("discounts", {
        name: "$5 Off",
        type: "FIXED_AMOUNT",
        discount_amount: 5.0,
        applies_to: "RECEIPT",
        enabled: false
      }).and_return(response)

      client.create_discount(
        name: "$5 Off",
        type: "FIXED_AMOUNT",
        discount_amount: 5.0,
        applies_to: "RECEIPT",
        enabled: false
      )
    end
  end

  describe "#update_discount" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "id" => "discount-123" }) }

    it "updates a discount" do
      expect(connection).to receive(:put).with("discounts/discount-123", { name: "15% Off" }).and_return(response)

      client.update_discount("discount-123", name: "15% Off")
    end

    it "updates multiple fields" do
      expect(connection).to receive(:put).with("discounts/discount-123", {
        name: "20% Off",
        discount_amount: 20.0,
        enabled: false
      }).and_return(response)

      client.update_discount("discount-123", name: "20% Off", discount_amount: 20.0, enabled: false)
    end
  end

  describe "#delete_discount" do
    let(:response) { instance_double(Faraday::Response, status: 204, body: nil) }

    it "deletes a discount" do
      expect(connection).to receive(:delete).with("discounts/discount-123").and_return(response)

      client.delete_discount("discount-123")
    end
  end
end
