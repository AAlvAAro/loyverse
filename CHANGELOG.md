# Changelog

## [0.2.0] - 2026-02-16

### Fixed
- Receipts resource
- `list_receipts` no longer sends an `order` query param by default — the live
  Loyverse API silently returns an empty `receipts` array whenever `order` is
  present (any value), so results were always empty even when matching receipts
  existed. Omitting it returns receipts newest-first already. `order` can still
  be passed explicitly, but be aware it currently breaks the request upstream.

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