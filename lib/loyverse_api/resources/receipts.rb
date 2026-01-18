module LoyverseApi
  module Resources
    class Receipts
      include Pagination

      def initialize(client)
        @client = client
      end

      # Get a specific receipt by receipt number
      # @param receipt_number [String, Integer] Receipt number (not UUID)
      # @return [Hash] Receipt details
      def get(receipt_number)
        @client.get("/receipts/#{receipt_number}")
      end
      alias_method :find, :get

      # List receipts
      # @param receipt_numbers [Array<String, Integer>] Array of specific receipt numbers (optional)
      # @param since_receipt_number [String, Integer] Return receipts after this number (optional)
      # @param before_receipt_number [String, Integer] Return receipts before this number (optional)
      # @param store_id [String] Filter by store UUID (optional)
      # @param order [String] Sort order: "ASC" or "DESC" (default: "DESC")
      # @param source [String] Filter by source (e.g., "POS", "API") (optional)
      # @param updated_at_min [String, Time] Filter by minimum update time (optional)
      # @param updated_at_max [String, Time] Filter by maximum update time (optional)
      # @param created_at_min [String, Time] Filter by minimum creation time (optional)
      # @param created_at_max [String, Time] Filter by maximum creation time (optional)
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @param auto_paginate [Boolean] If true, automatically fetches all pages (default: false)
      # @return [Array<Hash>, PaginatedCollection] Receipts array or paginated collection
      def list(
        receipt_numbers: nil,
        since_receipt_number: nil,
        before_receipt_number: nil,
        store_id: nil,
        order: "DESC",
        source: nil,
        updated_at_min: nil,
        updated_at_max: nil,
        created_at_min: nil,
        created_at_max: nil,
        limit: 250,
        cursor: nil,
        auto_paginate: false
      )
        params = { limit: limit, order: order }
        params[:receipt_numbers] = Array(receipt_numbers).join(",") if receipt_numbers
        params[:since_receipt_number] = since_receipt_number if since_receipt_number
        params[:before_receipt_number] = before_receipt_number if before_receipt_number
        params[:store_id] = store_id if store_id
        params[:source] = source if source
        params[:cursor] = cursor if cursor
        params[:updated_at_min] = format_time(updated_at_min) if updated_at_min
        params[:updated_at_max] = format_time(updated_at_max) if updated_at_max
        params[:created_at_min] = format_time(created_at_min) if created_at_min
        params[:created_at_max] = format_time(created_at_max) if created_at_max

        auto_paginate(
          "/receipts",
          params: params.merge(auto_paginate: auto_paginate),
          data_key: "receipts"
        )
      end
      alias_method :all, :list

      # Create a new receipt
      # @param receipt_date [String, Time] Receipt date in ISO 8601 format
      # @param store_id [String] UUID of the store
      # @param line_items [Array<Hash>] Array of line item hashes
      # @param payments [Array<Hash>] Array of payment hashes
      # @param receipt_type [String] Type of receipt (default: "SALE")
      # @param employee_id [String] UUID of the employee (optional)
      # @param customer_id [String] UUID of the customer (optional)
      # @param note [String] Receipt note (optional)
      # @param source [String] Source of receipt (default: "API")
      # @return [Hash] Created receipt details
      def create(
        receipt_date:,
        store_id:,
        line_items:,
        payments:,
        receipt_type: "SALE",
        employee_id: nil,
        customer_id: nil,
        note: nil,
        source: "API"
      )
        body = {
          receipt_date: format_time(receipt_date),
          receipt_type: receipt_type,
          store_id: store_id,
          line_items: line_items,
          payments: payments,
          source: source
        }
        body[:employee_id] = employee_id if employee_id
        body[:customer_id] = customer_id if customer_id
        body[:note] = note if note

        @client.post("/receipts", body: body)
      end

      # Create a refund for a receipt
      # @param receipt_number [String, Integer] Receipt number to refund
      # @param refund_date [String, Time] Refund date in ISO 8601 format
      # @param line_items [Array<Hash>] Array of line items to refund
      # @param payments [Array<Hash>] Array of refund payments
      # @param employee_id [String] UUID of the employee (optional)
      # @param note [String] Refund note (optional)
      # @return [Hash] Created refund receipt details
      def create_refund(receipt_number, refund_date:, line_items:, payments:, employee_id: nil, note: nil)
        body = {
          refund_date: format_time(refund_date),
          line_items: line_items,
          payments: payments
        }
        body[:employee_id] = employee_id if employee_id
        body[:note] = note if note

        @client.post("/receipts/#{receipt_number}/refund", body: body)
      end
      alias_method :refund, :create_refund

      # Get all receipts (auto-paginated)
      # @return [Array<Hash>] All receipts
      def all_receipts
        list(auto_paginate: true)
      end

      # Get receipts for a specific customer
      # @param customer_id [String] UUID of the customer
      # @return [Array<Hash>] Customer receipts (filtered client-side)
      def get_by_customer(customer_id)
        all_receipts.select { |receipt| receipt["customer_id"] == customer_id }
      end

      private

      def format_time(time)
        return time if time.is_a?(String)
        time.iso8601
      end
    end
  end
end
