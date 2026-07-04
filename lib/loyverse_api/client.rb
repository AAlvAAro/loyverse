# frozen_string_literal: true

module LoyverseApi
  class Client
    include Endpoints::Items
    include Endpoints::Categories
    include Endpoints::Inventory
    include Endpoints::Receipts
    include Endpoints::Webhooks
    include Endpoints::Customers
    include Endpoints::Discounts
    include Endpoints::Employees
    include Endpoints::Modifiers

    attr_reader :configuration

    def initialize(configuration = nil)
      @configuration = configuration || LoyverseApi.configuration || Configuration.new

      raise AuthenticationError, "Access token is required" if @configuration.access_token.nil?
    end

    def connection
      @connection ||= Faraday.new(url: configuration.base_url) do |conn|
        conn.request :json
        conn.request :retry, {
          max: 3,
          interval: 0.5,
          interval_randomness: 0.5,
          backoff_factor: 2,
          retry_statuses: [429, 500, 502, 503, 504],
          methods: [:get, :post, :put, :delete]
        }
        conn.response :json, content_type: /\bjson$/
        conn.headers['Authorization'] = "Bearer #{configuration.access_token}"
        conn.headers['Content-Type'] = 'application/json'
        conn.headers['Accept'] = 'application/json'
        conn.adapter Faraday.default_adapter
        conn.options.timeout = configuration.timeout
        conn.options.open_timeout = configuration.open_timeout
      end
    end

    def get(path, params: {})
      perform_request { connection.get(path, params) }
    end

    def post(path, body: {})
      perform_request { connection.post(path, body) }
    end

    def put(path, body: {})
      perform_request { connection.put(path, body) }
    end

    def delete(path)
      perform_request { connection.delete(path) }
    end

    private

    def perform_request
      handle_response(yield)
    rescue Faraday::TimeoutError
      raise Error, "Request timeout"
    rescue Faraday::ConnectionFailed
      raise Error, "Connection failed"
    end

    def handle_response(response)
      case response.status
      when 204
        nil
      when 200..299
        response.body
      when 400
        raise_api_error(BadRequestError, response.body, "Bad request")
      when 401
        raise_api_error(AuthenticationError, response.body, "Authentication failed")
      when 403
        raise_api_error(AuthorizationError, response.body, "Access forbidden")
      when 404
        raise_api_error(NotFoundError, response.body, "Not found")
      when 429
        raise_api_error(RateLimitError, response.body, "Rate limit exceeded")
      when 500..599
        raise_api_error(ServerError, response.body, "Server error occurred")
      else
        raise_api_error(ApiError, response.body, "Unknown error occurred")
      end
    end

    def raise_api_error(error_class, body, default_message)
      error = body.is_a?(Hash) ? body["error"] : nil

      message = (error.is_a?(Hash) && error["message"]) || (body.is_a?(Hash) && body["message"]) || default_message
      code = error.is_a?(Hash) ? error["code"] : nil
      details = error.is_a?(Hash) ? error["details"] : nil

      raise error_class.new(message, code: code, details: details)
    end

    # Formats time values to ISO 8601 format for Loyverse API
    #
    # The Loyverse API requires timestamps in ISO 8601 format (e.g., "2024-01-15T14:30:00.000Z")
    # This method handles different input types and converts them appropriately:
    #
    # @param time [String, Time, Date, nil] The time value to format
    # @return [String, nil] ISO 8601 formatted timestamp or nil
    #
    # @example String input (already formatted)
    #   format_time("2024-01-15T14:30:00.000Z") #=> "2024-01-15T14:30:00.000Z"
    #
    # @example Time object (with time component)
    #   format_time(Time.now) #=> "2024-01-15T14:30:00.123Z"
    #
    # @example Date object (no time component - sets to midnight UTC)
    #   format_time(Date.today) #=> "2024-01-15T00:00:00.000Z"
    #
    # @example Nil input
    #   format_time(nil) #=> nil
    def format_time(time)
      return nil if time.nil?
      return time if time.is_a?(String)

      # Date objects don't have hour method, so set to midnight UTC
      if time.respond_to?(:strftime) && !time.respond_to?(:hour)
        return "#{time.strftime('%Y-%m-%d')}T00:00:00.000Z"
      end

      # Time objects - convert to UTC and format with milliseconds
      return time.utc.strftime('%Y-%m-%dT%H:%M:%S.%LZ') if time.respond_to?(:utc)

      time
    end
  end
end
