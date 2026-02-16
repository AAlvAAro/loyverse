# Changelog

## [0.2.0] - 2026-02-16

### Fixed
- Receipts resource

### Changed
- Simplified response handling to let the user customize it

## [0.1.0] - 2026-02-16

### Added
- Initial release of the Loyverse API Ruby gem
- Comprehensive error handling
  - Custom exception classes for different error types
  - Automatic retry logic with exponential backoff
- Rate limiting support
  - Automatic retries for rate limit errors
  - Configurable timeout settings