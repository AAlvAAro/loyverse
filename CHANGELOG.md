# Changelog

## [1.0.0] - 2024-01-26

### Added
- Initial release of the Loyverse API Ruby gem
- Support for Personal Access Token authentication
- Complete implementation of Categories resource
  - List, get, create, and delete categories
- Complete implementation of Items resource
  - List, get, create, update, and delete items
  - Support for variants and product options
- Complete implementation of Inventory resource
  - Get inventory levels by variant or store
  - Update inventory levels
- Complete implementation of Receipts resource
  - List, get, and create receipts
  - Create refunds
  - Filter by store, date range, and source
- Complete implementation of Webhooks resource
  - List, get, create, and delete webhooks
  - Webhook signature verification
- Comprehensive error handling
  - Custom exception classes for different error types
  - Automatic retry logic with exponential backoff
- Rate limiting support
  - Automatic retries for rate limit errors
  - Configurable timeout settings
- ISO 8601 date/time handling
  - Automatic Time object conversion
  - Support for timezone-aware timestamps
- Detailed documentation and examples
  - README with usage examples
  - Inline documentation for all methods
  - YARD-compatible documentation strings

### Dependencies
- faraday ~> 2.0
- faraday-retry ~> 2.0

[1.0.0]: https://github.com/yourusername/loyverse_api/releases/tag/v1.0.0
