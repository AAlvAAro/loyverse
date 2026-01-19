RSpec.describe LoyverseApi::Endpoints::Receipts do
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

  describe "#get_receipt" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "receipt_number" => "123" }) }

    it "fetches a specific receipt by number" do
      expect(connection).to receive(:get).with("receipts/123", {}).and_return(response)

      result = client.get_receipt("123")

      expect(result).to eq({ "receipt_number" => "123" })
    end

    it "accepts integer receipt number" do
      expect(connection).to receive(:get).with("receipts/123", {}).and_return(response)

      client.get_receipt(123)
    end
  end

  describe "#list_receipts" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "receipts" => [] }) }

    it "lists receipts with default parameters" do
      expect(connection).to receive(:get).with("receipts", { limit: 250, order: "DESC" }).and_return(response)

      client.list_receipts
    end

    it "accepts custom limit and order" do
      expect(connection).to receive(:get).with("receipts", { limit: 100, order: "ASC" }).and_return(response)

      client.list_receipts(limit: 100, order: "ASC")
    end

    it "accepts receipt_numbers filter" do
      expect(connection).to receive(:get).with("receipts", hash_including(receipt_numbers: "123,456")).and_return(response)

      client.list_receipts(receipt_numbers: [123, 456])
    end

    it "accepts store_id filter" do
      expect(connection).to receive(:get).with("receipts", hash_including(store_id: "store-123")).and_return(response)

      client.list_receipts(store_id: "store-123")
    end

    it "accepts cursor" do
      expect(connection).to receive(:get).with("receipts", hash_including(cursor: "cursor123")).and_return(response)

      client.list_receipts(cursor: "cursor123")
    end
  end

  describe "#create_receipt" do
    let(:response) { instance_double(Faraday::Response, status: 201, body: { "receipt_number" => "456" }) }

    it "creates a receipt with required params" do
      expect(connection).to receive(:post).with("receipts", hash_including(
        store_id: "store-123",
        line_items: [{ variant_id: "var-1", quantity: 1 }],
        payments: [{ payment_type_id: "pay-1", amount: 10.0 }]
      )).and_return(response)

      client.create_receipt(
        receipt_date: "2024-01-01T12:00:00Z",
        store_id: "store-123",
        line_items: [{ variant_id: "var-1", quantity: 1 }],
        payments: [{ payment_type_id: "pay-1", amount: 10.0 }]
      )
    end
  end

  describe "#create_refund" do
    let(:response) { instance_double(Faraday::Response, status: 201, body: { "receipt_number" => "457" }) }

    it "creates a refund for a receipt" do
      expect(connection).to receive(:post).with("receipts/123/refund", hash_including(
        line_items: [{ variant_id: "var-1", quantity: 1 }],
        payments: [{ payment_type_id: "pay-1", amount: -10.0 }]
      )).and_return(response)

      client.create_refund(
        123,
        refund_date: "2024-01-02T12:00:00Z",
        line_items: [{ variant_id: "var-1", quantity: 1 }],
        payments: [{ payment_type_id: "pay-1", amount: -10.0 }]
      )
    end
  end
end
