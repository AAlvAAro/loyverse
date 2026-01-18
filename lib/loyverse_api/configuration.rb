module LoyverseApi
  class Configuration
    attr_accessor :access_token, :api_base_url, :api_version, :timeout, :open_timeout

    def initialize
      @api_base_url = "https://api.loyverse.com"
      @api_version = "v1.0"
      @timeout = 30
      @open_timeout = 10
      @access_token = nil
    end

    def base_url
      "#{@api_base_url}/#{@api_version}"
    end
  end
end
