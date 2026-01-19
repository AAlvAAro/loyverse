module LoyverseApi
  module Resources
    class Inventory
      include Pagination

      def initialize(client)
        @client = client
      end

      # Get inventory levels
      # @param variant_id [String] Filter by specific variant UUID (optional)
      # @param store_id [String] Filter by specific store UUID (optional)
      # @param updated_at_min [String, Time] Filter by minimum update time (optional)
      # @param updated_at_max [String, Time] Filter by maximum update time (optional)
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @param auto_paginate [Boolean] If true, automatically fetches all pages (default: false)
      # @return [Array<Hash>, PaginatedCollection] Inventory levels array or paginated collection
      def list(variant_id: nil, store_id: nil, updated_at_min: nil, updated_at_max: nil, limit: 250, cursor: nil, auto_paginate: false)
        params = { limit: limit }
        params[:variant_id] = variant_id if variant_id
        params[:store_id] = store_id if store_id
        params[:cursor] = cursor if cursor
        params[:updated_at_min] = format_time(updated_at_min) if updated_at_min
        params[:updated_at_max] = format_time(updated_at_max) if updated_at_max

        auto_paginate(
          "/inventory",
          params: params.merge(auto_paginate: auto_paginate),
          data_key: "inventory_levels"
        )
      end
      alias_method :all, :list
      alias_method :levels, :list

      # Update inventory level for a variant at a specific store
      # @param variant_id [String] UUID of the variant
      # @param store_id [String] UUID of the store
      # @param in_stock [Integer] New stock quantity
      # @return [Hash] Updated inventory level
      def update(variant_id:, store_id:, in_stock:)
        body = {
          variant_id: variant_id,
          store_id: store_id,
          in_stock: in_stock
        }

        @client.put("/inventory", body: body)
      end

      # Get inventory for a specific variant
      # @param variant_id [String] UUID of the variant
      # @return [Array<Hash>] Inventory levels for the variant across all stores
      def get_by_variant(variant_id)
        list(variant_id: variant_id, auto_paginate: true)
      end

      # Get inventory for a specific store
      # @param store_id [String] UUID of the store
      # @return [Array<Hash>] Inventory levels for all variants in the store
      def get_by_store(store_id)
        list(store_id: store_id, auto_paginate: true)
      end
    end
  end
end
