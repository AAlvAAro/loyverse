# frozen_string_literal: true

module LoyverseApi
  module Endpoints
    module Discounts
      # Discount type constants
      TYPE_FIXED_PERCENT = "FIXED_PERCENT"
      TYPE_FIXED_AMOUNT = "FIXED_AMOUNT"
      TYPE_VARIABLE_PERCENT = "VARIABLE_PERCENT"
      TYPE_VARIABLE_AMOUNT = "VARIABLE_AMOUNT"
      TYPE_DISCOUNT_BY_POINTS = "DISCOUNT_BY_POINTS"

      # Applies to constants
      APPLIES_TO_RECEIPT = "RECEIPT"
      APPLIES_TO_ITEM = "ITEM"

      # Default applies_to value
      DEFAULT_APPLIES_TO = APPLIES_TO_RECEIPT

      # Get a specific discount by ID
      # @param discount_id [String] UUID of the discount
      # @return [Hash] Discount details
      def get_discount(discount_id)
        get("discounts/#{discount_id}")
      end

      # List discounts
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @param updated_at_min [String, Time] Filter by minimum update time (ISO 8601)
      # @param updated_at_max [String, Time] Filter by maximum update time (ISO 8601)
      # @return [Hash] Response with discounts array
      def list_discounts(limit: 250, cursor: nil, updated_at_min: nil, updated_at_max: nil)
        params = {
          limit: limit,
          cursor: cursor,
          updated_at_min: format_time(updated_at_min),
          updated_at_max: format_time(updated_at_max)
        }.compact

        get("discounts", params: params)
      end

      # Create a new discount
      # @param name [String] Discount name
      # @param type [String] Type of discount: "FIXED_PERCENT", "FIXED_AMOUNT", "VARIABLE_PERCENT", "VARIABLE_AMOUNT", or "DISCOUNT_BY_POINTS"
      # @param discount_amount [Float] Discount amount (percentage or fixed value, optional for variable types)
      # @param applies_to [String] What the discount applies to: "RECEIPT" or "ITEM" (optional, default: "RECEIPT")
      # @param enabled [Boolean] Whether the discount is enabled (optional)
      # @return [Hash] Created discount details
      def create_discount(name:, type:, discount_amount: nil, applies_to: DEFAULT_APPLIES_TO, enabled: true)
        body = {
          name: name,
          type: type.upcase,
          discount_amount: discount_amount,
          applies_to: applies_to.upcase,
          enabled: enabled
        }.compact

        post("discounts", body: body)
      end

      # Update an existing discount
      # @param discount_id [String] UUID of the discount
      # @param name [String] Discount name (optional)
      # @param type [String] Type of discount: "FIXED_PERCENT", "FIXED_AMOUNT", "VARIABLE_PERCENT", "VARIABLE_AMOUNT", or "DISCOUNT_BY_POINTS" (optional)
      # @param discount_amount [Float] Discount amount (optional)
      # @param applies_to [String] What the discount applies to (optional)
      # @param enabled [Boolean] Whether the discount is enabled (optional)
      # @return [Hash] Updated discount details
      def update_discount(discount_id, name: nil, type: nil, discount_amount: nil, applies_to: nil, enabled: nil)
        body = {
          name: name,
          type: type&.upcase,
          discount_amount: discount_amount,
          applies_to: applies_to&.upcase,
          enabled: enabled
        }.compact

        put("discounts/#{discount_id}", body: body)
      end

      # Delete a discount
      # @param discount_id [String] UUID of the discount
      # @return [Hash] Response
      def delete_discount(discount_id)
        delete("discounts/#{discount_id}")
      end
    end
  end
end
