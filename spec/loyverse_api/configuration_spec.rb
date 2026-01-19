RSpec.describe LoyverseApi::Configuration do
  describe "#initialize" do
    it "sets default values" do
      config = described_class.new

      expect(config.api_base_url).to eq("https://api.loyverse.com/v1.0/")
      expect(config.timeout).to eq(30)
      expect(config.open_timeout).to eq(10)
      expect(config.access_token).to be_nil
    end
  end

  describe "#base_url" do
    it "is an alias for api_base_url" do
      config = described_class.new

      expect(config.base_url).to eq("https://api.loyverse.com/v1.0/")
      expect(config.base_url).to eq(config.api_base_url)
    end

    it "uses custom values when set" do
      config = described_class.new
      config.api_base_url = "https://custom.api.com/v2.0"

      expect(config.base_url).to eq("https://custom.api.com/v2.0")
    end
  end

  describe "attribute accessors" do
    it "allows setting and getting access_token" do
      config = described_class.new
      config.access_token = "test_token_123"

      expect(config.access_token).to eq("test_token_123")
    end

    it "allows setting and getting timeout" do
      config = described_class.new
      config.timeout = 60

      expect(config.timeout).to eq(60)
    end

    it "allows setting and getting open_timeout" do
      config = described_class.new
      config.open_timeout = 20

      expect(config.open_timeout).to eq(20)
    end
  end
end
