module LoyverseApi
  module Endpoints
    module Inventory
      # List inventory levels
      # @param variant_id [String] Filter by specific variant UUID (optional)
      # @param store_id [String] Filter by specific store UUID (optional)
      # @param updated_at_min [String, Time] Filter by minimum update time (optional)
      # @param updated_at_max [String, Time] Filter by maximum update time (optional)
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @return [Hash] Response with inventory levels array
      def list_inventory(variant_id: nil, store_id: nil, updated_at_min: nil, updated_at_max: nil, limit: 250, cursor: nil)
        params = {
          limit: limit,
          variant_id: variant_id,
          store_id: store_id,
          cursor: cursor,
          updated_at_min: format_time(updated_at_min),
          updated_at_max: format_time(updated_at_max)
        }.compact

        get("inventory", params: params)
      end

      # Update inventory level for a variant at a specific store
      # @param variant_id [String] UUID of the variant
      # @param store_id [String] UUID of the store
      # @param in_stock [Integer] New stock quantity
      # @return [Hash] Updated inventory level
      def update_inventory(variant_id:, store_id:, in_stock:)
        body = {
          variant_id: variant_id,
          store_id: store_id,
          in_stock: in_stock
        }

        put("inventory", body: body)
      end
    end
  end
end
