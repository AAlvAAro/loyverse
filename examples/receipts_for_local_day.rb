#!/usr/bin/env ruby

require 'bundler/setup'
require 'dotenv/load'
require 'date'
require 'loyverse_api'

# Demonstrates computing a *local* business day's boundaries and converting
# them to UTC before querying receipts — the Loyverse API only understands
# UTC, so a naive "00:00 to 24:00 UTC" window does not line up with a local
# calendar day unless the store is in UTC+0. See the "Timezones and 'today'
# boundaries" section of the README for background.

LoyverseApi.configure do |config|
  config.access_token = ENV['LOYVERSE_ACCESS_TOKEN']
end

client = LoyverseApi.client

# Adjust these for the store you're reporting on — this gem doesn't wrap the
# Stores endpoint and has no built-in notion of timezone, so your app needs
# to track this itself if it spans multiple timezones.
UTC_OFFSET = '-06:00' # CST (Mexico City), no DST as of the 2022 reform
local_day = Date.today

day_start_utc = Time.new(local_day.year, local_day.month, local_day.day, 0, 0, 0, UTC_OFFSET).utc
day_end_utc = day_start_utc + (24 * 60 * 60)

def fetch_all_receipts(client, created_at_min:, created_at_max:)
  receipts = []
  cursor = nil

  loop do
    response = client.list_receipts(
      limit: 250,
      created_at_min: created_at_min,
      created_at_max: created_at_max,
      cursor: cursor
    )
    batch = response['receipts'] || []
    receipts.concat(batch)
    cursor = response['cursor']
    break if cursor.nil? || batch.empty?
  end

  receipts
end

receipts = fetch_all_receipts(client, created_at_min: day_start_utc, created_at_max: day_end_utc)
valid_receipts = receipts.reject { |r| r['cancelled_at'] }
cancelled_count = receipts.size - valid_receipts.size

total_sales = valid_receipts.sum { |r| r['total_money'] }
total_discounts = valid_receipts.sum { |r| r['total_discount'] || 0 }

puts "Local day: #{local_day} (UTC offset #{UTC_OFFSET})"
puts "UTC window: #{day_start_utc.iso8601} to #{day_end_utc.iso8601}"
puts "Receipts: #{receipts.size} (#{cancelled_count} cancelled, excluded from totals)"
puts "Total sales: %.2f" % total_sales
puts "Total discounts: %.2f" % total_discounts
