#!/usr/bin/env ruby

require 'bundler/setup'
require 'dotenv/load'
require 'loyverse_api'

LoyverseApi.configure do |config|
  config.access_token = ENV['LOYVERSE_ACCESS_TOKEN']
end

client = LoyverseApi.client

response = client.list_receipts(limit: 10)
receipts = response['receipts'] || []

if receipts.empty?
  puts 'No receipts found'
else
  receipts.each do |receipt|
    puts "Receipt ##{receipt['receipt_number']} — #{receipt['receipt_date']} — total #{receipt['total_money']}"
  end
end
