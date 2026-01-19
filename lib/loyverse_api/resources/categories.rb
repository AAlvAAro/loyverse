module LoyverseApi
  module Resources
    class Categories
      include Pagination

      def initialize(client)
        @client = client
      end

      # Get a specific category by ID
      # @param category_id [String] UUID of the category
      # @return [Hash] Category details
      def get(category_id)
        @client.get("/categories/#{category_id}")
      end
      alias_method :find, :get

      # List all categories
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @param auto_paginate [Boolean] If true, automatically fetches all pages (default: false)
      # @return [Array<Hash>, PaginatedCollection] Categories array or paginated collection
      def list(limit: 250, cursor: nil, auto_paginate: false)
        params = { limit: limit }
        params[:cursor] = cursor if cursor

        if auto_paginate
          auto_paginate(
            "/categories",
            params: params,
            data_key: "categories"
          )
        else
          @client.get("/categories", params: params)
        end
      end
      alias_method :all, :list

      # Create a new category
      # @param name [String] Category name
      # @param color [String] Color code (e.g., "ORANGE", "RED", "BLUE")
      # @return [Hash] Created category details
      def create(name:, color: nil)
        body = { name: name }
        body[:color] = color if color

        @client.post("/categories", body: body)
      end

      # Delete a category
      # @param category_id [String] UUID of the category
      # @return [Hash] Response
      def delete(category_id)
        @client.delete("/categories/#{category_id}")
      end

      # Get all categories (auto-paginated)
      # @return [Array<Hash>] All categories
      def all_categories
        list(auto_paginate: true)
      end
    end
  end
end
