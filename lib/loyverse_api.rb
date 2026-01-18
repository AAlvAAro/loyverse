require "faraday"
require "faraday/retry"
require "json"
require "time"

require_relative "loyverse_api/version"
require_relative "loyverse_api/configuration"
require_relative "loyverse_api/errors"
require_relative "loyverse_api/client"
require_relative "loyverse_api/pagination"
require_relative "loyverse_api/resources/categories"
require_relative "loyverse_api/resources/items"
require_relative "loyverse_api/resources/inventory"
require_relative "loyverse_api/resources/receipts"
require_relative "loyverse_api/resources/webhooks"

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
