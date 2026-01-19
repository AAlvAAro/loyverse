module LoyverseApi
  module Endpoints
    module Categories
      # Get a specific category by ID
      # @param category_id [String] UUID of the category
      # @return [Hash] Category details
      def get_category(category_id)
        get("categories/#{category_id}")
      end

      # List all categories
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @return [Hash] Response with categories array
      def list_categories(limit: 250, cursor: nil)
        params = {
          limit: limit,
          cursor: cursor
        }.compact

        get("categories", params: params)
      end

      # Create a new category
      # @param name [String] Category name
      # @param color [String] Color code (e.g., "ORANGE", "RED", "BLUE")
      # @return [Hash] Created category details
      def create_category(name:, color: nil)
        body = { name: name }
        body[:color] = color if color

        post("categories", body: body)
      end

      # Delete a category
      # @param category_id [String] UUID of the category
      # @return [Hash] Response
      def delete_category(category_id)
        delete("categories/#{category_id}")
      end
    end
  end
end
