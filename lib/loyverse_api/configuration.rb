module LoyverseApi
  class Configuration
    attr_accessor :access_token, :api_base_url, :timeout, :open_timeout
    alias_method :base_url, :api_base_url

    def initialize
      @api_base_url = "https://api.loyverse.com/v1.0/"
      @timeout = 30
      @open_timeout = 10
      @access_token = nil
    end
  end
end
