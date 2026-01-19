RSpec.describe LoyverseApi::Error do
  describe "#initialize" do
    it "sets message" do
      error = described_class.new("Test error")

      expect(error.message).to eq("Test error")
    end

    it "sets code when provided" do
      error = described_class.new("Test error", code: "ERR_001")

      expect(error.code).to eq("ERR_001")
    end

    it "sets details when provided" do
      details = { field: "email", issue: "invalid" }
      error = described_class.new("Test error", details: details)

      expect(error.details).to eq(details)
    end

    it "sets all attributes" do
      details = { field: "email" }
      error = described_class.new("Test error", code: "ERR_001", details: details)

      expect(error.message).to eq("Test error")
      expect(error.code).to eq("ERR_001")
      expect(error.details).to eq(details)
    end
  end

  describe "error inheritance" do
    it "AuthenticationError inherits from Error" do
      expect(LoyverseApi::AuthenticationError.new).to be_a(LoyverseApi::Error)
    end

    it "AuthorizationError inherits from Error" do
      expect(LoyverseApi::AuthorizationError.new).to be_a(LoyverseApi::Error)
    end

    it "NotFoundError inherits from Error" do
      expect(LoyverseApi::NotFoundError.new).to be_a(LoyverseApi::Error)
    end

    it "BadRequestError inherits from Error" do
      expect(LoyverseApi::BadRequestError.new).to be_a(LoyverseApi::Error)
    end

    it "RateLimitError inherits from Error" do
      expect(LoyverseApi::RateLimitError.new).to be_a(LoyverseApi::Error)
    end

    it "ServerError inherits from Error" do
      expect(LoyverseApi::ServerError.new).to be_a(LoyverseApi::Error)
    end

    it "ApiError inherits from Error" do
      expect(LoyverseApi::ApiError.new).to be_a(LoyverseApi::Error)
    end
  end
end
