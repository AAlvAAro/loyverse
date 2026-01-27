module LoyverseApi
  module Endpoints
    module Customers
      # Get a specific customer by ID
      # @param customer_id [String] UUID of the customer
      # @return [Hash] Customer details
      def get_customer(customer_id)
        get("customers/#{customer_id}")
      end

      # List customers
      # @param limit [Integer] Maximum number of results per page (default: 250)
      # @param cursor [String] Pagination cursor for next page
      # @param email [String] Filter by email address (optional)
      # @param phone_number [String] Filter by phone number (optional)
      # @param updated_at_min [String, Time] Filter by minimum update time (ISO 8601)
      # @param updated_at_max [String, Time] Filter by maximum update time (ISO 8601)
      # @return [Hash] Response with customers array
      def list_customers(limit: 250, cursor: nil, email: nil, phone_number: nil, updated_at_min: nil, updated_at_max: nil)
        params = {
          limit: limit,
          cursor: cursor,
          email: email,
          phone_number: phone_number,
          updated_at_min: format_time(updated_at_min),
          updated_at_max: format_time(updated_at_max)
        }.compact

        get("customers", params: params)
      end

      # Create a new customer
      # @param name [String] Customer name
      # @param email [String] Customer email (optional)
      # @param phone_number [String] Customer phone number (optional)
      # @param address [String] Customer address (optional)
      # @param city [String] Customer city (optional)
      # @param region [String] Customer region/state (optional)
      # @param postal_code [String] Customer postal code (optional)
      # @param country [String] Customer country (optional)
      # @param customer_code [String] Custom customer code (optional)
      # @param note [String] Customer note (optional)
      # @param first_visit [String, Time] Date of first visit (optional)
      # @param total_visits [Integer] Total number of visits (optional)
      # @param total_spent [Float] Total amount spent (optional)
      # @return [Hash] Created customer details
      def create_customer(
        name:,
        email: nil,
        phone_number: nil,
        address: nil,
        city: nil,
        region: nil,
        postal_code: nil,
        country: nil,
        customer_code: nil,
        note: nil,
        first_visit: nil,
        total_visits: nil,
        total_spent: nil
      )
        body = {
          name: name,
          email: email,
          phone_number: phone_number,
          address: address,
          city: city,
          region: region,
          postal_code: postal_code,
          country: country,
          customer_code: customer_code,
          note: note,
          first_visit: format_time(first_visit),
          total_visits: total_visits,
          total_spent: total_spent
        }.compact

        post("customers", body: body)
      end

      # Update an existing customer
      # @param customer_id [String] UUID of the customer
      # @param name [String] Customer name (optional)
      # @param email [String] Customer email (optional)
      # @param phone_number [String] Customer phone number (optional)
      # @param address [String] Customer address (optional)
      # @param city [String] Customer city (optional)
      # @param region [String] Customer region/state (optional)
      # @param postal_code [String] Customer postal code (optional)
      # @param country [String] Customer country (optional)
      # @param customer_code [String] Custom customer code (optional)
      # @param note [String] Customer note (optional)
      # @return [Hash] Updated customer details
      def update_customer(
        customer_id,
        name: nil,
        email: nil,
        phone_number: nil,
        address: nil,
        city: nil,
        region: nil,
        postal_code: nil,
        country: nil,
        customer_code: nil,
        note: nil
      )
        body = {
          name: name,
          email: email,
          phone_number: phone_number,
          address: address,
          city: city,
          region: region,
          postal_code: postal_code,
          country: country,
          customer_code: customer_code,
          note: note
        }.compact

        put("customers/#{customer_id}", body: body)
      end

      # Delete a customer
      # @param customer_id [String] UUID of the customer
      # @return [Hash] Response
      def delete_customer(customer_id)
        delete("customers/#{customer_id}")
      end
    end
  end
end
