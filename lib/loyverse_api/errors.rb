module LoyverseApi
  class Error < StandardError
    attr_reader :code, :details

    def initialize(message = nil, code: nil, details: nil)
      @code = code
      @details = details
      super(message)
    end
  end

  class AuthenticationError < Error; end
  class AuthorizationError < Error; end
  class NotFoundError < Error; end
  class BadRequestError < Error; end
  class RateLimitError < Error; end
  class ServerError < Error; end
  class ApiError < Error; end
end
