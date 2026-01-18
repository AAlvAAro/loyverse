RSpec.describe LoyverseApi::Client do
  let(:configuration) do
    config = LoyverseApi::Configuration.new
    config.access_token = "test_token"
    config
  end

  let(:client) { described_class.new(configuration) }

  describe "#initialize" do
    it "raises an error without access token" do
      config = LoyverseApi::Configuration.new
      expect { described_class.new(config) }.to raise_error(LoyverseApi::AuthenticationError)
    end

    it "creates resource instances" do
      expect(client.categories).to be_a(LoyverseApi::Resources::Categories)
      expect(client.items).to be_a(LoyverseApi::Resources::Items)
      expect(client.inventory).to be_a(LoyverseApi::Resources::Inventory)
      expect(client.receipts).to be_a(LoyverseApi::Resources::Receipts)
      expect(client.webhooks).to be_a(LoyverseApi::Resources::Webhooks)
    end
  end

  describe "#connection" do
    it "creates a Faraday connection with correct settings" do
      connection = client.connection
      expect(connection).to be_a(Faraday::Connection)
      expect(connection.headers['Authorization']).to eq("Bearer test_token")
      expect(connection.headers['Content-Type']).to eq('application/json')
    end
  end
end
