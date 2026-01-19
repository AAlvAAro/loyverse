#!/usr/bin/env ruby

require 'bundler/setup'
require 'loyverse_api'

# This example demonstrates basic usage of the Loyverse API gem

# Configure the gem with your access token
LoyverseApi.configure do |config|
  config.access_token = ENV['LOYVERSE_ACCESS_TOKEN'] || 'your_access_token_here'
end

# Create a client instance
client = LoyverseApi.client

puts "=== Loyverse API Examples ==="
puts

# Example 1: List Categories
puts "1. Listing categories:"
begin
  categories = client.categories.list(limit: 5)
  if categories.empty?
    puts "  No categories found"
  else
    categories.each do |category|
      puts "  - #{category['name']} (#{category['color']})"
    end
  end
rescue LoyverseApi::Error => e
  puts "  Error: #{e.message}"
end
puts

# Example 2: List Items
puts "2. Listing items:"
begin
  items = client.items.list(limit: 5)
  if items.empty?
    puts "  No items found"
  else
    items.each do |item|
      puts "  - #{item['item_name']}"
      if item['variants']
        item['variants'].each do |variant|
          puts "    * SKU: #{variant['sku']}, Price: $#{variant['price']}"
        end
      end
    end
  end
rescue LoyverseApi::Error => e
  puts "  Error: #{e.message}"
end
puts

# Example 3: Get Inventory Levels
puts "3. Checking inventory:"
begin
  inventory = client.inventory.list(limit: 5)
  if inventory.empty?
    puts "  No inventory data found"
  else
    inventory.each do |level|
      puts "  - Variant: #{level['variant_id']}"
      puts "    Store: #{level['store_id']}"
      puts "    In Stock: #{level['in_stock']}"
      puts "    Updated: #{level['updated_at']}"
      puts
    end
  end
rescue LoyverseApi::Error => e
  puts "  Error: #{e.message}"
end
puts

# Example 4: List Recent Receipts
puts "4. Listing recent receipts:"
begin
  receipts = client.receipts.list(limit: 5, order: 'DESC')
  if receipts.empty?
    puts "  No receipts found"
  else
    receipts.each do |receipt|
      puts "  - Receipt ##{receipt['receipt_number']}"
      puts "    Date: #{receipt['receipt_date']}"
      puts "    Total: $#{receipt['total_money']}"
      puts "    Items: #{receipt['line_items']&.count || 0}"
      puts
    end
  end
rescue LoyverseApi::Error => e
  puts "  Error: #{e.message}"
end
puts

# Example 5: List Webhooks
puts "5. Listing webhooks:"
begin
  webhooks = client.webhooks.list
  if webhooks.empty?
    puts "  No webhooks configured"
  else
    webhooks.each do |webhook|
      puts "  - #{webhook['url']}"
      puts "    Events: #{webhook['event_types']&.join(', ')}"
      puts "    Description: #{webhook['description']}"
      puts
    end
  end
rescue LoyverseApi::Error => e
  puts "  Error: #{e.message}"
end
puts

puts "=== Examples Complete ==="
