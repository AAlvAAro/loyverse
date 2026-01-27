RSpec.describe LoyverseApi::Endpoints::Employees do
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

  describe "#get_employee" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "id" => "employee-123" }) }

    it "fetches a specific employee by ID" do
      expect(connection).to receive(:get).with("employees/employee-123", {}).and_return(response)

      result = client.get_employee("employee-123")

      expect(result).to eq({ "id" => "employee-123" })
    end
  end

  describe "#list_employees" do
    let(:response) { instance_double(Faraday::Response, status: 200, body: { "employees" => [] }) }

    it "lists employees with default parameters" do
      expect(connection).to receive(:get).with("employees", { limit: 250 }).and_return(response)

      client.list_employees
    end

    it "accepts custom limit" do
      expect(connection).to receive(:get).with("employees", { limit: 100 }).and_return(response)

      client.list_employees(limit: 100)
    end

    it "accepts cursor" do
      expect(connection).to receive(:get).with("employees", { limit: 250, cursor: "cursor123" }).and_return(response)

      client.list_employees(cursor: "cursor123")
    end

    it "accepts time filters" do
      expect(connection).to receive(:get).with("employees", hash_including(:updated_at_min, :updated_at_max)).and_return(response)

      client.list_employees(updated_at_min: "2024-01-01T00:00:00Z", updated_at_max: "2024-12-31T23:59:59Z")
    end
  end
end
