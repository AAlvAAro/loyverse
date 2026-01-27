# frozen_string_literal: true

module LoyverseApi
  module Endpoints
    module Modifiers
      # Get a specific modifier by ID
      # @param modifier_id [String] UUID of the modifier
      # @return [Hash] Modifier details
      def get_modifier(modifier_id)
        get("modifiers/#{modifier_id}")
      end

      # List modifiers
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @param updated_at_min [String, Time] Filter by minimum update time (ISO 8601)
      # @param updated_at_max [String, Time] Filter by maximum update time (ISO 8601)
      # @return [Hash] Response with modifiers array
      def list_modifiers(limit: 250, cursor: nil, updated_at_min: nil, updated_at_max: nil)
        params = {
          limit: limit,
          cursor: cursor,
          updated_at_min: format_time(updated_at_min),
          updated_at_max: format_time(updated_at_max)
        }.compact

        get("modifiers", params: params)
      end

      # Create a new modifier
      # @param name [String] Modifier name
      # @param options [Array<Hash>] Array of modifier options with name and price
      # @return [Hash] Created modifier details
      def create_modifier(name:, options:)
        body = {
          name: name,
          options: options
        }

        post("modifiers", body: body)
      end

      # Delete a modifier
      # @param modifier_id [String] UUID of the modifier
      # @return [Hash] Response
      def delete_modifier(modifier_id)
        delete("modifiers/#{modifier_id}")
      end
    end
  end
end
