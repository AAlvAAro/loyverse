require "faraday"
require "faraday/retry"
require "json"
require "time"

require_relative "loyverse_api/version"
require_relative "loyverse_api/configuration"
require_relative "loyverse_api/errors"
require_relative "loyverse_api/endpoints/items"
require_relative "loyverse_api/endpoints/categories"
require_relative "loyverse_api/endpoints/inventory"
require_relative "loyverse_api/endpoints/receipts"
require_relative "loyverse_api/endpoints/webhooks"
require_relative "loyverse_api/client"

module LoyverseApi
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.client
    Client.new(configuration)
  end
end
