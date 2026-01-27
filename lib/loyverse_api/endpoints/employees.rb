# frozen_string_literal: true

module LoyverseApi
  module Endpoints
    module Employees
      # Get a specific employee by ID
      # @param employee_id [String] UUID of the employee
      # @return [Hash] Employee details
      def get_employee(employee_id)
        get("employees/#{employee_id}")
      end

      # List employees
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @param updated_at_min [String, Time] Filter by minimum update time (ISO 8601)
      # @param updated_at_max [String, Time] Filter by maximum update time (ISO 8601)
      # @return [Hash] Response with employees array
      def list_employees(limit: 250, cursor: nil, updated_at_min: nil, updated_at_max: nil)
        params = {
          limit: limit,
          cursor: cursor,
          updated_at_min: format_time(updated_at_min),
          updated_at_max: format_time(updated_at_max)
        }.compact

        get("employees", params: params)
      end
    end
  end
end
