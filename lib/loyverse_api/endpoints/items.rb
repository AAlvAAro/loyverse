module LoyverseApi
  module Endpoints
    module Items
      # Get a specific item by ID
      # @param item_id [String] UUID of the item
      # @return [Hash] Item details
      def get_item(item_id)
        get("items/#{item_id}")
      end

      # List items
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @param updated_at_min [String, Time] Filter by minimum update time (ISO 8601)
      # @param updated_at_max [String, Time] Filter by maximum update time (ISO 8601)
      # @return [Hash] Response with items array
      def list_items(limit: 250, cursor: nil, updated_at_min: nil, updated_at_max: nil)
        params = {
          limit: limit,
          cursor: cursor,
          updated_at_min: format_time(updated_at_min),
          updated_at_max: format_time(updated_at_max)
        }.compact

        get("items", params: params)
      end

      # Create a new item
      # @param item_name [String] Name of the item
      # @param category_id [String] UUID of the category (optional)
      # @param variants [Array<Hash>] Array of variant hashes
      # @param track_stock [Boolean] Whether to track inventory
      # @param sold_by_weight [Boolean] Whether item is sold by weight
      # @param is_composite [Boolean] Whether item is composite
      # @return [Hash] Created item details
      def create_item(item_name:, category_id: nil, variants: [], track_stock: false, sold_by_weight: false, is_composite: false)
        body = {
          item_name: item_name,
          track_stock: track_stock,
          sold_by_weight: sold_by_weight,
          is_composite: is_composite
        }
        body[:category_id] = category_id if category_id
        body[:variants] = variants unless variants.empty?

        post("items", body: body)
      end

      # Update an existing item
      # @param item_id [String] UUID of the item
      # @param item_name [String] Name of the item (optional)
      # @param category_id [String] UUID of the category (optional)
      # @param variants [Array<Hash>] Array of variant hashes (optional)
      # @param track_stock [Boolean] Whether to track inventory (optional)
      # @return [Hash] Updated item details
      def update_item(item_id, item_name: nil, category_id: nil, variants: nil, track_stock: nil)
        body = {
          item_name: item_name,
          category_id: category_id,
          variants: variants,
          track_stock: track_stock
        }.compact

        put("items/#{item_id}", body: body)
      end

      # Delete an item
      # @param item_id [String] UUID of the item
      # @return [Hash] Response
      def delete_item(item_id)
        delete("items/#{item_id}")
      end
    end
  end
end
