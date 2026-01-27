# frozen_string_literal: true

module LoyverseApi
  class Client
    include Endpoints::Items
    include Endpoints::Categories
    include Endpoints::Inventory
    include Endpoints::Receipts
    include Endpoints::Webhooks
    include Endpoints::Customers

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
      handle_response do
        response = connection.get(path, params)
        response
      end
    end

    def post(path, body: {})
      handle_response do
        response = connection.post(path, body)
        response
      end
    end

    def put(path, body: {})
      handle_response do
        response = connection.put(path, body)
        response
      end
    end

    def delete(path)
      handle_response do
        response = connection.delete(path)
        response
      end
    end

    private

    def handle_response
      response = yield

      case response.status
      when 200, 201, 204
        response.body
      when 400
        raise BadRequestError.new(
          error_message(response) || "Bad Request: #{response.body.inspect}",
          code: error_code(response),
          details: error_details(response)
        )
      when 401
        raise AuthenticationError.new(
          error_message(response),
          code: error_code(response),
          details: error_details(response)
        )
      when 403
        raise AuthorizationError.new(
          error_message(response),
          code: error_code(response),
          details: error_details(response)
        )
      when 404
        raise NotFoundError.new(
          error_message(response),
          code: error_code(response),
          details: error_details(response)
        )
      when 429
        raise RateLimitError.new(
          error_message(response) || "Rate limit exceeded",
          code: error_code(response),
          details: error_details(response)
        )
      when 500, 502, 503, 504
        raise ServerError.new(
          error_message(response) || "Server error occurred",
          code: error_code(response),
          details: error_details(response)
        )
      else
        raise ApiError.new(
          error_message(response) || "Unknown error occurred",
          code: error_code(response),
          details: error_details(response)
        )
      end
    rescue Faraday::TimeoutError
      raise Error, "Request timeout"
    rescue Faraday::ConnectionFailed
      raise Error, "Connection failed"
    end

    def error_message(response)
      return nil unless response.body.is_a?(Hash)
      response.body.dig("error", "message") || response.body["message"]
    end

    def error_code(response)
      return nil unless response.body.is_a?(Hash)
      response.body.dig("error", "code")
    end

    def error_details(response)
      return nil unless response.body.is_a?(Hash)
      response.body.dig("error", "details")
    end

    def format_time(time)
      return nil if time.nil?
      return time if time.is_a?(String)

      if time.respond_to?(:strftime) && !time.respond_to?(:hour)
        return "#{time.strftime('%Y-%m-%d')}T00:00:00.000Z"
      end

      return time.utc.strftime('%Y-%m-%dT%H:%M:%S.%LZ') if time.respond_to?(:utc)

      time
    end
  end
end
