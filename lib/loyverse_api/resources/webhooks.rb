module LoyverseApi
  module Resources
    class Webhooks
      include Pagination

      def initialize(client)
        @client = client
      end

      # Get a specific webhook by ID
      # @param webhook_id [String] UUID of the webhook
      # @return [Hash] Webhook details
      def get(webhook_id)
        @client.get("/webhooks/#{webhook_id}")
      end
      alias_method :find, :get

      # List all webhooks
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @param auto_paginate [Boolean] If true, automatically fetches all pages (default: false)
      # @return [Array<Hash>, PaginatedCollection] Webhooks array or paginated collection
      def list(limit: 250, cursor: nil, auto_paginate: false)
        params = { limit: limit }
        params[:cursor] = cursor if cursor

        auto_paginate(
          "/webhooks",
          params: params.merge(auto_paginate: auto_paginate),
          data_key: "webhooks"
        )
      end
      alias_method :all, :list

      # Create a new webhook
      # @param url [String] Webhook endpoint URL
      # @param event_types [Array<String>] Array of event types to subscribe to
      # @param description [String] Webhook description (optional)
      # @return [Hash] Created webhook details
      #
      # Available event types:
      # - ORDER_CREATED
      # - ITEM_UPDATED
      # - INVENTORY_UPDATED
      def create(url:, event_types:, description: nil)
        body = {
          url: url,
          event_types: Array(event_types)
        }
        body[:description] = description if description

        @client.post("/webhooks", body: body)
      end

      # Delete a webhook
      # @param webhook_id [String] UUID of the webhook
      # @return [Hash] Response
      def delete(webhook_id)
        @client.delete("/webhooks/#{webhook_id}")
      end

      # Verify webhook signature (for OAuth 2.0 created webhooks)
      # @param payload [String] Raw request body
      # @param signature [String] X-Loyverse-Signature header value
      # @param secret [String] Your webhook secret
      # @return [Boolean] True if signature is valid
      def verify_signature(payload, signature, secret)
        require "openssl"

        computed_signature = OpenSSL::HMAC.hexdigest(
          OpenSSL::Digest.new("sha256"),
          secret,
          payload
        )

        secure_compare(computed_signature, signature)
      end

      # Get all webhooks (auto-paginated)
      # @return [Array<Hash>] All webhooks
      def all_webhooks
        list(auto_paginate: true)
      end

      private

      # Constant-time string comparison to prevent timing attacks
      def secure_compare(a, b)
        return false if a.nil? || b.nil? || a.bytesize != b.bytesize

        l = a.unpack("C*")
        r = 0
        i = -1

        b.each_byte { |byte| r |= byte ^ l[i += 1] }
        r == 0
      end
    end
  end
end
