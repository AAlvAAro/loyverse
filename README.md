# Loyverse API Ruby Gem

A comprehensive Ruby wrapper for the [Loyverse API](https://developer.loyverse.com/docs/), providing easy access to all Loyverse resources including items, inventory, receipts, categories, and webhooks.

## Features

- **Complete API Coverage**: Support for all major Loyverse API resources
- **Authentication**: Personal Access Token and OAuth 2.0 support
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

<details>
<summary>Click to see Categories examples</summary>

```ruby
# List categories
categories = client.list_categories

# Get a specific category
category = client.get_category('category-uuid')

# Create a category
new_category = client.create_category(
  name: 'Beverages',
  color: 'BLUE'
)

# Delete a category
client.delete_category('category-uuid')
```

</details>

### Items

<details>
<summary>Click to see Items examples</summary>

```ruby
# List items
items = client.list_items(limit: 50)

# Get items updated after a specific date
recent_items = client.list_items(
  updated_at_min: Time.now - (7 * 24 * 60 * 60)
)

# Get a specific item
item = client.get_item('item-uuid')

# Create an item with variants
new_item = client.create_item(
  item_name: 'Coffee',
  category_id: 'category-uuid',
  track_stock: true,
  variants: [
    {
      sku: 'COFFEE-S',
      price: 3.50,
      cost: 1.50
    }
  ]
)

# Update an item
client.update_item(
  'item-uuid',
  item_name: 'Premium Coffee'
)

# Delete an item
client.delete_item('item-uuid')
```

</details>

### Inventory

<details>
<summary>Click to see Inventory examples</summary>

```ruby
# List inventory levels
inventory = client.list_inventory

# Filter by variant
variant_inventory = client.list_inventory(variant_id: 'variant-uuid')

# Filter by store
store_inventory = client.list_inventory(store_id: 'store-uuid')

# Update inventory level
client.update_inventory(
  variant_id: 'variant-uuid',
  store_id: 'store-uuid',
  in_stock: 150
)
```

</details>

### Receipts

<details>
<summary>Click to see Receipts examples</summary>

```ruby
# List receipts
receipts = client.list_receipts(order: 'DESC')

# Filter by store
store_receipts = client.list_receipts(store_id: 'store-uuid')

# Filter by date range
receipts_by_date = client.list_receipts(
  created_at_min: '2024-01-01T00:00:00Z',
  created_at_max: '2024-01-31T23:59:59Z'
)

# Get a specific receipt
receipt = client.get_receipt('12345')

# Create a receipt
new_receipt = client.create_receipt(
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
  ]
)

# Create a refund
refund = client.create_refund(
  '12345',
  refund_date: Time.now,
  line_items: [...],
  payments: [...]
)
```

</details>

### Customers

<details>
<summary>Click to see Customers examples</summary>

```ruby
# List customers
customers = client.list_customers

# Filter by email
customer = client.list_customers(email: 'customer@example.com')

# Filter by phone
customer = client.list_customers(phone_number: '+1234567890')

# Get a specific customer
customer = client.get_customer('customer-uuid')

# Create a customer
new_customer = client.create_customer(
  name: 'John Doe',
  email: 'john@example.com',
  phone_number: '+1234567890',
  address: '123 Main St',
  city: 'New York',
  postal_code: '10001'
)

# Update a customer
client.update_customer(
  'customer-uuid',
  name: 'Jane Doe',
  email: 'jane@example.com'
)

# Delete a customer
client.delete_customer('customer-uuid')
```

</details>

### Webhooks

<details>
<summary>Click to see Webhooks examples</summary>

```ruby
# List webhooks
webhooks = client.list_webhooks

# Get a specific webhook
webhook = client.get_webhook('webhook-uuid')

# Create a webhook
new_webhook = client.create_webhook(
  url: 'https://your-server.com/webhooks/loyverse',
  event_types: ['ORDER_CREATED', 'ITEM_UPDATED'],
  description: 'Production webhook'
)

# Delete a webhook
client.delete_webhook('webhook-uuid')

# Verify webhook signature
is_valid = client.verify_webhook_signature(
  request.raw_post,
  request.headers['X-Loyverse-Signature'],
  'your_webhook_secret'
)
```

</details>

### Pagination

```ruby
# Get first page
page = client.list_items(limit: 100)

# Get next page using cursor from response
next_page = client.list_items(limit: 100, cursor: page['cursor'])
```

### Error Handling

The gem provides specific exception classes for different error types:

```ruby
begin
  item = client.get_item('invalid-uuid')
rescue LoyverseApi::NotFoundError => e
  puts "Item not found: #{e.message}"
rescue LoyverseApi::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
rescue LoyverseApi::RateLimitError => e
  puts "Rate limit exceeded: #{e.message}"
rescue LoyverseApi::BadRequestError => e
  puts "Bad request: #{e.message}"
  puts "Error code: #{e.code}"
  puts "Error details: #{e.details}"
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
