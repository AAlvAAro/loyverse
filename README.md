# Loyverse API Ruby Gem

A comprehensive Ruby wrapper for the [Loyverse API](https://developer.loyverse.com/docs/), providing easy access to all Loyverse resources including items, inventory, receipts, categories, and webhooks.

## Features

- **Complete API Coverage**: Support for all major Loyverse API resources
- **Authentication**: Personal Access Token and OAuth 2.0 support
- **Automatic Pagination**: Built-in support for cursor-based pagination
- **Error Handling**: Comprehensive error handling with custom exception classes
- **Rate Limiting**: Automatic retry logic with exponential backoff
- **Type Safety**: Well-documented methods with clear parameter types
- **Webhook Support**: Signature verification for secure webhook handling

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'loyverse_api'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install loyverse_api
```

## Quick Start

### Configuration

Configure the gem with your Personal Access Token:

```ruby
require 'loyverse_api'

LoyverseApi.configure do |config|
  config.access_token = 'your_access_token_here'
end

# Create a client instance
client = LoyverseApi.client
```

Alternatively, you can create a client directly:

```ruby
configuration = LoyverseApi::Configuration.new
configuration.access_token = 'your_access_token_here'

client = LoyverseApi::Client.new(configuration)
```

### Getting Your Access Token

1. Login to [Loyverse Back Office](https://r.loyverse.com/dashboard)
2. Navigate to 'Access Tokens' section
3. Click '+ Add access token'
4. Fill in name and optional expiration date
5. Save and copy the token (shown only once)

## Usage

### Categories

```ruby
# List all categories
categories = client.categories.list
categories.each do |category|
  puts "#{category['name']}: #{category['color']}"
end

# Auto-paginate through all categories
all_categories = client.categories.list(auto_paginate: true)

# Get a specific category
category = client.categories.get('category-uuid')

# Create a new category
new_category = client.categories.create(
  name: 'Beverages',
  color: 'BLUE'
)

# Delete a category
client.categories.delete('category-uuid')
```

### Items

```ruby
# List all items
items = client.items.list(limit: 50)

# Get items updated after a specific date
require 'time'
recent_items = client.items.list(
  updated_at_min: Time.now - (7 * 24 * 60 * 60), # Last 7 days
  auto_paginate: true
)

# Get a specific item
item = client.items.get('item-uuid')

# Create a new item with variants
new_item = client.items.create(
  item_name: 'Coffee',
  category_id: 'category-uuid',
  track_stock: true,
  variants: [
    {
      sku: 'COFFEE-S',
      barcode: '123456789',
      price: 3.50,
      cost: 1.50,
      option1_value: 'Small'
    },
    {
      sku: 'COFFEE-L',
      barcode: '987654321',
      price: 5.00,
      cost: 2.00,
      option1_value: 'Large'
    }
  ]
)

# Update an item
client.items.update(
  'item-uuid',
  item_name: 'Premium Coffee',
  category_id: 'new-category-uuid'
)

# Delete an item
client.items.delete('item-uuid')
```

### Inventory

**Important**: Use the inventory endpoint for stock levels, NOT the items endpoint.

```ruby
# Get all inventory levels
inventory = client.inventory.list

# Get inventory for a specific variant
variant_inventory = client.inventory.get_by_variant('variant-uuid')

# Get inventory for a specific store
store_inventory = client.inventory.get_by_store('store-uuid')

# Get inventory updated in the last hour
recent_inventory = client.inventory.list(
  updated_at_min: Time.now - 3600,
  auto_paginate: true
)

# Update inventory level
client.inventory.update(
  variant_id: 'variant-uuid',
  store_id: 'store-uuid',
  in_stock: 150
)
```

### Receipts

```ruby
# List all receipts
receipts = client.receipts.list(order: 'DESC')

# Get receipts for a specific store
store_receipts = client.receipts.list(
  store_id: 'store-uuid',
  limit: 100
)

# Get receipts created in a date range
receipts_by_date = client.receipts.list(
  created_at_min: '2024-01-01T00:00:00Z',
  created_at_max: '2024-01-31T23:59:59Z',
  auto_paginate: true
)

# Get a specific receipt by receipt number
receipt = client.receipts.get('12345')

# Create a new receipt
new_receipt = client.receipts.create(
  receipt_date: Time.now,
  store_id: 'store-uuid',
  line_items: [
    {
      variant_id: 'variant-uuid',
      quantity: 2,
      price: 10.00
    }
  ],
  payments: [
    {
      payment_type_id: 'payment-type-uuid',
      money_amount: 20.00
    }
  ],
  customer_id: 'customer-uuid',
  employee_id: 'employee-uuid',
  note: 'Special order'
)

# Create a refund
refund = client.receipts.create_refund(
  '12345', # receipt number to refund
  refund_date: Time.now,
  line_items: [
    {
      variant_id: 'variant-uuid',
      quantity: 1,
      price: 10.00
    }
  ],
  payments: [
    {
      payment_type_id: 'payment-type-uuid',
      money_amount: 10.00
    }
  ],
  note: 'Customer requested refund'
)

# Get receipts for a specific customer (filtered client-side)
customer_receipts = client.receipts.get_by_customer('customer-uuid')
```

### Webhooks

```ruby
# List all webhooks
webhooks = client.webhooks.list

# Get a specific webhook
webhook = client.webhooks.get('webhook-uuid')

# Create a new webhook
new_webhook = client.webhooks.create(
  url: 'https://your-server.com/webhooks/loyverse',
  event_types: ['ORDER_CREATED', 'ITEM_UPDATED', 'INVENTORY_UPDATED'],
  description: 'Production webhook'
)

# Delete a webhook
client.webhooks.delete('webhook-uuid')

# Verify webhook signature (for OAuth 2.0 created webhooks)
is_valid = client.webhooks.verify_signature(
  request.raw_post,           # Raw request body
  request.headers['X-Loyverse-Signature'],
  'your_webhook_secret'
)
```

### Pagination

The gem supports both manual and automatic pagination:

#### Manual Pagination

```ruby
# Get first page
page = client.items.list(limit: 100)

# Check if there are more pages
if page.has_more?
  # Get next page using cursor
  next_page = client.items.list(limit: 100, cursor: page.cursor)
end

# Iterate through items in current page
page.each do |item|
  puts item['item_name']
end
```

#### Automatic Pagination

```ruby
# Automatically fetch all pages
all_items = client.items.list(auto_paginate: true)

# This returns an array of all items across all pages
all_items.each do |item|
  puts item['item_name']
end
```

### Error Handling

The gem provides specific exception classes for different error types:

```ruby
begin
  item = client.items.get('invalid-uuid')
rescue LoyverseApi::NotFoundError => e
  puts "Item not found: #{e.message}"
rescue LoyverseApi::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
rescue LoyverseApi::AuthorizationError => e
  puts "Not authorized: #{e.message}"
rescue LoyverseApi::RateLimitError => e
  puts "Rate limit exceeded: #{e.message}"
  # The gem automatically retries with exponential backoff
rescue LoyverseApi::BadRequestError => e
  puts "Bad request: #{e.message}"
  puts "Error code: #{e.code}"
  puts "Error details: #{e.details}"
rescue LoyverseApi::ServerError => e
  puts "Server error: #{e.message}"
rescue LoyverseApi::Error => e
  puts "API error: #{e.message}"
end
```

### Date and Time Handling

All dates in the Loyverse API use ISO 8601 format. The gem automatically handles Time objects:

```ruby
# Using Time objects (recommended)
items = client.items.list(
  updated_at_min: Time.now - (7 * 24 * 60 * 60), # 7 days ago
  updated_at_max: Time.now
)

# Using ISO 8601 strings
items = client.items.list(
  updated_at_min: '2024-01-15T00:00:00Z',
  updated_at_max: '2024-01-22T23:59:59Z'
)
```

## Configuration Options

```ruby
LoyverseApi.configure do |config|
  # Required: Your Personal Access Token
  config.access_token = 'your_token'

  # Optional: API base URL (default: 'https://api.loyverse.com')
  config.api_base_url = 'https://api.loyverse.com'

  # Optional: API version (default: 'v1.0')
  config.api_version = 'v1.0'

  # Optional: Request timeout in seconds (default: 30)
  config.timeout = 30

  # Optional: Connection open timeout in seconds (default: 10)
  config.open_timeout = 10
end
```

## Rate Limiting

The Loyverse API has the following rate limits:

- **Standard**: 60 requests per minute
- **Alternative**: 300 requests per 300 seconds

The gem automatically handles rate limiting with:

- Automatic retry with exponential backoff
- Maximum 3 retry attempts
- Retries for 429, 500, 502, 503, 504 status codes

## Available Event Types for Webhooks

- `ORDER_CREATED` - New receipts/sales
- `ITEM_UPDATED` - Product changes
- `INVENTORY_UPDATED` - Stock level changes

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Resources

- [Loyverse API Documentation](https://developer.loyverse.com/docs/)
- [Loyverse Developer Portal](https://developer.loyverse.com)
- [Loyverse Back Office](https://r.loyverse.com/dashboard)

## Support

For issues related to the gem, please open an issue on GitHub.

For Loyverse API support, please contact [Loyverse Support](https://loyverse.com/support).
