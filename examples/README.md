# Loyverse API Examples

This directory contains example code and sample API responses for the Loyverse API Ruby gem.

## Sample API Responses

### Receipts

See [`receipt_response_sample.json`](receipt_response_sample.json) for a complete example of a receipt object returned by the Loyverse API.

This sample demonstrates:
- **Receipt metadata**: receipt number, type, dates, source
- **Financial data**: totals, taxes, discounts, tips
- **Line items**: products with quantities, prices, costs
- **Modifiers**: customizations applied to items (e.g., milk type, flavor syrups, extra shots)
- **Payments**: payment methods and amounts
- **Pagination**: cursor for fetching additional results

#### Key Fields

**Receipt Level:**
- `receipt_number`: Unique receipt identifier (e.g., "1-10131")
- `receipt_type`: Type of transaction ("SALE", "REFUND", etc.)
- `total_money`: Total amount including tax
- `total_tax`: Total tax amount
- `employee_id`: ID of the employee who processed the sale
- `store_id`: ID of the store where the sale occurred
- `dining_option`: Customer's dining preference

**Line Items:**
- `item_name`: Product name
- `sku`: Stock keeping unit
- `quantity`: Number of items sold
- `price`: Base price per item
- `total_money`: Total for this line item including modifiers
- `cost`: Cost of goods sold
- `line_modifiers`: Array of customizations applied

**Modifiers:**
- `name`: Modifier category (e.g., "Flavor Syrup", "Espresso Shot")
- `option`: Selected option (e.g., "Chocolate", "Double Shot Extra")
- `price`: Additional charge for the modifier
- `money_amount`: Total amount for this modifier

**Payments:**
- `type`: Payment method ("CASH", "CARD", etc.)
- `money_amount`: Amount paid
- `paid_at`: Timestamp of payment

## Usage Examples

### Fetching Receipts

```ruby
require 'loyverse_api'

# Configure the client
LoyverseApi.configure do |config|
  config.access_token = ENV['LOYVERSE_ACCESS_TOKEN']
end

client = LoyverseApi.client

# List recent receipts
receipts = client.list_receipts(limit: 100)

# List receipts in a date range
receipts = client.list_receipts(
  limit: 100,
  created_at_min: '2025-07-01T00:00:00.000Z',
  created_at_max: '2025-07-31T23:59:59.999Z'
)

# List receipts between specific receipt numbers
receipts = client.list_receipts(
  limit: 250,
  since_receipt_number: '1-10129',
  before_receipt_number: '1-10132'
)

# Paginate through results
page1 = client.list_receipts(limit: 100)
page2 = client.list_receipts(limit: 100, cursor: page1['cursor'])
```

### Processing Receipt Data

```ruby
receipts['receipts'].each do |receipt|
  puts "Receipt: #{receipt['receipt_number']}"
  puts "Total: $#{receipt['total_money']}"
  puts "Date: #{receipt['receipt_date']}"
  
  # Process line items
  receipt['line_items'].each do |item|
    puts "  - #{item['item_name']}: #{item['quantity']} x $#{item['price']}"
    
    # Process modifiers
    item['line_modifiers']&.each do |modifier|
      puts "    + #{modifier['name']}: #{modifier['option']} (+$#{modifier['price']})"
    end
  end
  
  puts "---"
end
```

## Additional Resources

- [Loyverse API Documentation](https://developer.loyverse.com/docs/)
- [Main README](../README.md)
