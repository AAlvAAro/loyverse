module LoyverseApi
  module Endpoints
    module Webhooks
      # Get a specific webhook by ID
      # @param webhook_id [String] UUID of the webhook
      # @return [Hash] Webhook details
      def get_webhook(webhook_id)
        get("webhooks/#{webhook_id}")
      end

      # List all webhooks
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @return [Hash] Response with webhooks array
      def list_webhooks(limit: 250, cursor: nil)
        params = {
          limit: limit,
          cursor: cursor
        }.compact

        get("webhooks", params: params)
      end

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
      def create_webhook(url:, event_types:, description: nil)
        body = {
          url: url,
          event_types: Array(event_types)
        }
        body[:description] = description if description

        post("webhooks", body: body)
      end

      # Delete a webhook
      # @param webhook_id [String] UUID of the webhook
      # @return [Hash] Response
      def delete_webhook(webhook_id)
        delete("webhooks/#{webhook_id}")
      end

      # Verify webhook signature (for OAuth 2.0 created webhooks)
      # @param payload [String] Raw request body
      # @param signature [String] X-Loyverse-Signature header value
      # @param secret [String] Your webhook secret
      # @return [Boolean] True if signature is valid
      def verify_webhook_signature(payload, signature, secret)
        return false if payload.nil? || signature.nil? || secret.nil?

        require "openssl"

        computed_signature = OpenSSL::HMAC.hexdigest(
          OpenSSL::Digest.new("sha256"),
          secret,
          payload
        )

        secure_compare(computed_signature, signature)
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
