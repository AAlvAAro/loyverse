#!/usr/bin/env ruby

require 'bundler/setup'
require 'loyverse_api'

# This example demonstrates how to create a new item with variants

LoyverseApi.configure do |config|
  config.access_token = ENV['LOYVERSE_ACCESS_TOKEN'] || 'your_access_token_here'
end

client = LoyverseApi.client

puts "Creating a new item with variants..."
puts

begin
  # First, create a category for the item
  category = client.categories.create(
    name: 'Beverages',
    color: 'BLUE'
  )
  puts "Created category: #{category['name']} (ID: #{category['id']})"
  puts

  # Create an item with multiple variants
  item = client.items.create(
    item_name: 'Premium Coffee',
    category_id: category['id'],
    track_stock: true,
    variants: [
      {
        sku: 'COFFEE-S-001',
        barcode: '1234567890123',
        price: 3.50,
        cost: 1.50,
        option1_value: 'Small'
      },
      {
        sku: 'COFFEE-M-001',
        barcode: '1234567890124',
        price: 4.50,
        cost: 2.00,
        option1_value: 'Medium'
      },
      {
        sku: 'COFFEE-L-001',
        barcode: '1234567890125',
        price: 5.50,
        cost: 2.50,
        option1_value: 'Large'
      }
    ]
  )

  puts "Created item: #{item['item_name']}"
  puts "Item ID: #{item['id']}"
  puts "Category: #{item['category_id']}"
  puts
  puts "Variants:"
  item['variants'].each do |variant|
    puts "  - #{variant['option1_value']}: $#{variant['price']} (SKU: #{variant['sku']})"
  end
  puts
  puts "Item created successfully!"

rescue LoyverseApi::Error => e
  puts "Error creating item: #{e.message}"
  puts "Error code: #{e.code}" if e.code
  puts "Error details: #{e.details}" if e.details
end
