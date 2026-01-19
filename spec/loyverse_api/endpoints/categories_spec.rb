RSpec.describe LoyverseApi::Endpoints::Categories do
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

  describe "#get_category" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "id" => "cat-123" }) }

    it "fetches a specific category by ID" do
      expect(connection).to receive(:get).with("categories/cat-123", {}).and_return(response)

      result = client.get_category("cat-123")

      expect(result).to eq({ "id" => "cat-123" })
    end
  end

  describe "#list_categories" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "categories" => [] }) }

    it "lists categories with default parameters" do
      expect(connection).to receive(:get).with("categories", { limit: 250 }).and_return(response)

      client.list_categories
    end

    it "accepts cursor for pagination" do
      expect(connection).to receive(:get).with("categories", { limit: 250, cursor: "cursor123" }).and_return(response)

      client.list_categories(cursor: "cursor123")
    end
  end

  describe "#create_category" do
    let(:response) { instance_double(Faraday::Response, status: 201, body: { "id" => "new-cat" }) }

    it "creates a category with name only" do
      expect(connection).to receive(:post).with("categories", { name: "Test Category" }).and_return(response)

      client.create_category(name: "Test Category")
    end

    it "creates a category with name and color" do
      expect(connection).to receive(:post).with("categories", { name: "Test Category", color: "ORANGE" }).and_return(response)

      client.create_category(name: "Test Category", color: "ORANGE")
    end
  end

  describe "#delete_category" do
    let(:response) { instance_double(Faraday::Response, status: 204, body: nil) }

    it "deletes a category" do
      expect(connection).to receive(:delete).with("categories/cat-123").and_return(response)

      client.delete_category("cat-123")
    end
  end
end
