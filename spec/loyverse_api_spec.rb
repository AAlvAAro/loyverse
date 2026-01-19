RSpec.describe LoyverseApi do
  it "has a version number" do
    expect(LoyverseApi::VERSION).not_to be nil
  end

  describe ".configure" do
    it "allows configuration" do
      LoyverseApi.configure do |config|
        config.access_token = "test_token"
        config.timeout = 60
      end

      expect(LoyverseApi.configuration.access_token).to eq("test_token")
      expect(LoyverseApi.configuration.timeout).to eq(60)
    end
  end

  describe ".client" do
    before do
      LoyverseApi.configure do |config|
        config.access_token = "test_token"
      end
    end

    it "returns a client instance" do
      client = LoyverseApi.client
      expect(client).to be_a(LoyverseApi::Client)
    end
  end
end
