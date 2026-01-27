RSpec.describe LoyverseApi::Endpoints::Customers do
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

  describe "#get_customer" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "id" => "customer-123" }) }

    it "fetches a specific customer by ID" do
      expect(connection).to receive(:get).with("customers/customer-123", {}).and_return(response)

      result = client.get_customer("customer-123")

      expect(result).to eq({ "id" => "customer-123" })
    end
  end

  describe "#list_customers" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "customers" => [] }) }

    it "lists customers with default parameters" do
      expect(connection).to receive(:get).with("customers", { limit: 250 }).and_return(response)

      client.list_customers
    end

    it "accepts custom limit" do
      expect(connection).to receive(:get).with("customers", { limit: 100 }).and_return(response)

      client.list_customers(limit: 100)
    end

    it "accepts cursor" do
      expect(connection).to receive(:get).with("customers", { limit: 250, cursor: "cursor123" }).and_return(response)

      client.list_customers(cursor: "cursor123")
    end

    it "accepts email filter" do
      expect(connection).to receive(:get).with("customers", { limit: 250, email: "test@example.com" }).and_return(response)

      client.list_customers(email: "test@example.com")
    end

    it "accepts phone_number filter" do
      expect(connection).to receive(:get).with("customers", { limit: 250, phone_number: "+1234567890" }).and_return(response)

      client.list_customers(phone_number: "+1234567890")
    end

    it "accepts time filters" do
      expect(connection).to receive(:get).with("customers", hash_including(:updated_at_min, :updated_at_max)).and_return(response)

      client.list_customers(updated_at_min: "2024-01-01T00:00:00Z", updated_at_max: "2024-12-31T23:59:59Z")
    end
  end

  describe "#create_customer" do
    let(:response) { instance_double(Faraday::Response, status: 201, body: { "id" => "new-customer" }) }

    it "creates a customer with minimal params" do
      expect(connection).to receive(:post).with("customers", { name: "John Doe" }).and_return(response)

      client.create_customer(name: "John Doe")
    end

    it "creates a customer with all params" do
      expect(connection).to receive(:post).with("customers", hash_including(
        name: "John Doe",
        email: "john@example.com",
        phone_number: "+1234567890",
        address: "123 Main St",
        city: "New York",
        region: "NY",
        postal_code: "10001",
        country: "US",
        customer_code: "CUST001",
        note: "VIP customer"
      )).and_return(response)

      client.create_customer(
        name: "John Doe",
        email: "john@example.com",
        phone_number: "+1234567890",
        address: "123 Main St",
        city: "New York",
        region: "NY",
        postal_code: "10001",
        country: "US",
        customer_code: "CUST001",
        note: "VIP customer"
      )
    end
  end

  describe "#update_customer" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "id" => "customer-123" }) }

    it "updates a customer" do
      expect(connection).to receive(:put).with("customers/customer-123", { name: "Jane Doe" }).and_return(response)

      client.update_customer("customer-123", name: "Jane Doe")
    end

    it "updates multiple fields" do
      expect(connection).to receive(:put).with("customers/customer-123", {
        name: "Jane Doe",
        email: "jane@example.com",
        phone_number: "+9876543210"
      }).and_return(response)

      client.update_customer("customer-123", name: "Jane Doe", email: "jane@example.com", phone_number: "+9876543210")
    end
  end

  describe "#delete_customer" do
    let(:response) { instance_double(Faraday::Response, status: 204, body: nil) }

    it "deletes a customer" do
      expect(connection).to receive(:delete).with("customers/customer-123").and_return(response)

      client.delete_customer("customer-123")
    end
  end
end
