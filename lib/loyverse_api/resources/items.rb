module LoyverseApi
  module Resources
    class Items
      include Pagination

      def initialize(client)
        @client = client
      end

      # Get a specific item by ID
      # @param item_id [String] UUID of the item
      # @return [Hash] Item details
      def get(item_id)
        @client.get("/items/#{item_id}")
      end
      alias_method :find, :get

      # List all items
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @param updated_at_min [String, Time] Filter by minimum update time (ISO 8601)
      # @param updated_at_max [String, Time] Filter by maximum update time (ISO 8601)
      # @param auto_paginate [Boolean] If true, automatically fetches all pages (default: false)
      # @return [Array<Hash>, PaginatedCollection] Items array or paginated collection
      def list(limit: 250, cursor: nil, updated_at_min: nil, updated_at_max: nil, auto_paginate: false)
        params = { limit: limit }
        params[:cursor] = cursor if cursor
        params[:updated_at_min] = format_time(updated_at_min) if updated_at_min
        params[:updated_at_max] = format_time(updated_at_max) if updated_at_max

        auto_paginate(
          "/items",
          params: params.merge(auto_paginate: auto_paginate),
          data_key: "items"
        )
      end
      alias_method :all, :list

      # Create a new item
      # @param item_name [String] Name of the item
      # @param category_id [String] UUID of the category (optional)
      # @param variants [Array<Hash>] Array of variant hashes
      # @param track_stock [Boolean] Whether to track inventory
      # @param sold_by_weight [Boolean] Whether item is sold by weight
      # @param is_composite [Boolean] Whether item is composite
      # @return [Hash] Created item details
      def create(item_name:, category_id: nil, variants: [], track_stock: false, sold_by_weight: false, is_composite: false)
        body = {
          item_name: item_name,
          track_stock: track_stock,
          sold_by_weight: sold_by_weight,
          is_composite: is_composite
        }
        body[:category_id] = category_id if category_id
        body[:variants] = variants unless variants.empty?

        @client.post("/items", body: body)
      end

      # Update an existing item
      # @param item_id [String] UUID of the item
      # @param item_name [String] Name of the item (optional)
      # @param category_id [String] UUID of the category (optional)
      # @param variants [Array<Hash>] Array of variant hashes (optional)
      # @param track_stock [Boolean] Whether to track inventory (optional)
      # @return [Hash] Updated item details
      def update(item_id, item_name: nil, category_id: nil, variants: nil, track_stock: nil)
        body = {}
        body[:item_name] = item_name if item_name
        body[:category_id] = category_id if category_id
        body[:variants] = variants if variants
        body[:track_stock] = track_stock unless track_stock.nil?

        @client.put("/items/#{item_id}", body: body)
      end

      # Delete an item
      # @param item_id [String] UUID of the item
      # @return [Hash] Response
      def delete(item_id)
        @client.delete("/items/#{item_id}")
      end

      # Get all items (auto-paginated)
      # @return [Array<Hash>] All items
      def all_items
        list(auto_paginate: true)
      end

      private

      def format_time(time)
        return time if time.is_a?(String)
        time.iso8601
      end
    end
  end
end
