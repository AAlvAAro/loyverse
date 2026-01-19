#!/usr/bin/env ruby

require 'bundler/setup'
require 'loyverse_api'
require 'webrick'
require 'json'

# This example demonstrates a simple webhook receiver server

# Configure the Loyverse API client
LoyverseApi.configure do |config|
  config.access_token = ENV['LOYVERSE_ACCESS_TOKEN'] || 'your_access_token_here'
end

client = LoyverseApi.client

# Webhook secret (if using OAuth 2.0 created webhooks)
WEBHOOK_SECRET = ENV['LOYVERSE_WEBHOOK_SECRET']

# Simple webhook handler
class WebhookHandler < WEBrick::HTTPServlet::AbstractServlet
  def initialize(server, client)
    super(server)
    @client = client
  end

  def do_POST(request, response)
    begin
      # Get the raw body
      body = request.body

      # Verify signature if using OAuth 2.0
      if WEBHOOK_SECRET
        signature = request.header['x-loyverse-signature']&.first
        is_valid = @client.webhooks.verify_signature(body, signature, WEBHOOK_SECRET)

        unless is_valid
          response.status = 401
          response.body = JSON.generate({ error: 'Invalid signature' })
          return
        end
      end

      # Parse the webhook payload
      payload = JSON.parse(body)

      # Handle the webhook event
      handle_event(payload)

      # Respond with 200 OK
      response.status = 200
      response['Content-Type'] = 'application/json'
      response.body = JSON.generate({ received: true })

    rescue JSON::ParserError => e
      response.status = 400
      response.body = JSON.generate({ error: 'Invalid JSON' })
    rescue => e
      puts "Error processing webhook: #{e.message}"
      response.status = 500
      response.body = JSON.generate({ error: 'Internal server error' })
    end
  end

  private

  def handle_event(payload)
    event_type = payload['event_type']
    data = payload['data']
    timestamp = payload['timestamp']

    puts "\n=== Webhook Received ==="
    puts "Event Type: #{event_type}"
    puts "Timestamp: #{timestamp}"
    puts "Data: #{JSON.pretty_generate(data)}"
    puts "========================\n"

    case event_type
    when 'ORDER_CREATED'
      handle_order_created(data)
    when 'ITEM_UPDATED'
      handle_item_updated(data)
    when 'INVENTORY_UPDATED'
      handle_inventory_updated(data)
    else
      puts "Unknown event type: #{event_type}"
    end
  end

  def handle_order_created(data)
    puts "New order created: Receipt ##{data['receipt_number']}"
    # Add your custom logic here
  end

  def handle_item_updated(data)
    puts "Item updated: #{data['item_name']}"
    # Add your custom logic here
  end

  def handle_inventory_updated(data)
    puts "Inventory updated for variant: #{data['variant_id']}"
    puts "New stock level: #{data['in_stock']}"
    # Add your custom logic here
  end
end

# Create and start the server
port = ENV['PORT'] || 3000
server = WEBrick::HTTPServer.new(Port: port)

server.mount '/webhooks/loyverse', WebhookHandler, client

trap('INT') { server.shutdown }

puts "Webhook server listening on port #{port}"
puts "Webhook URL: http://localhost:#{port}/webhooks/loyverse"
puts "Press Ctrl+C to stop"
puts

server.start
