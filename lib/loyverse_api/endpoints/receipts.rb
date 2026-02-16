module LoyverseApi
  module Endpoints
    module Receipts
      # Get a specific receipt by receipt number
      # @param receipt_number [String, Integer] Receipt number (not UUID)
      # @return [Hash] Receipt details
      def get_receipt(receipt_number)
        get("receipts/#{receipt_number}")
      end

      # List receipts
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param options [Hash] Optional filters
      # @option options [Array<String, Integer>] :receipt_numbers Array of specific receipt numbers
      # @option options [String, Integer] :since_receipt_number Return receipts after this number
      # @option options [String, Integer] :before_receipt_number Return receipts before this number
      # @option options [String] :store_id Filter by store UUID
      # @option options [String] :source Filter by source (e.g., "POS", "API")
      # @option options [String, Time] :updated_at_min Filter by minimum update time
      # @option options [String, Time] :updated_at_max Filter by maximum update time
      # @option options [String, Time] :created_at_min Filter by minimum creation time
      # @option options [String, Time] :created_at_max Filter by maximum creation time
      # @option options [String] :cursor Pagination cursor for next page
      # @return [Hash] Response with receipts array
      def list_receipts(limit: 100, **options)
        params = {
          limit: limit,
          receipt_numbers: options[:receipt_numbers] ? Array(options[:receipt_numbers]).join(",") : nil,
          since_receipt_number: options[:since_receipt_number],
          before_receipt_number: options[:before_receipt_number],
          store_id: options[:store_id],
          source: options[:source],
          cursor: options[:cursor],
          updated_at_min: format_time(options[:updated_at_min]),
          updated_at_max: format_time(options[:updated_at_max]),
          created_at_min: format_time(options[:created_at_min]),
          created_at_max: format_time(options[:created_at_max])
        }.compact

        get("receipts", params: params)
      end

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
      def create_receipt(
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

        post("receipts", body: body)
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

        post("receipts/#{receipt_number}/refund", body: body)
      end
    end
  end
end
