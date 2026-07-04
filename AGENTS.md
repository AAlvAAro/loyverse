# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, Copilot, etc.) working in this repo.

## What this is

`loyverse_api` is a Ruby gem that wraps the [Loyverse API](https://developer.loyverse.com/docs/)
(a POS/retail platform). It gives Ruby apps a `client` object with one method per API
operation (`client.list_items`, `client.create_receipt`, etc.), handles auth, retries,
and error mapping. It has no runtime dependency on Rails — it's a plain gem meant to be
required by other apps.

Current version: see `lib/loyverse_api/version.rb`. Change history: `CHANGELOG.md`.

## Setup

```bash
bundle install
cp .env.sample .env   # then fill in a real LOYVERSE_ACCESS_TOKEN if you need to hit the live API
```

Requires Ruby >= 2.6.0 (see `loyverse_api.gemspec`). No database, no external services
required to run the test suite — tests stub HTTP at the Faraday connection level.

## Running tests

```bash
bundle exec rspec            # preferred, runs the whole suite
rake spec                    # equivalent, via Rakefile (default rake task)
bundle exec rspec spec/loyverse_api/endpoints/receipts_spec.rb   # single file
bundle exec rspec spec/loyverse_api/endpoints/receipts_spec.rb:42  # single example by line
```

`.rspec` sets `--format documentation` and auto-requires `spec_helper`. `spec_helper.rb`
loads `dotenv/load` (so `.env` is picked up), `webmock/rspec`, and `vcr` — but in practice
every existing spec mocks `client.connection` directly with
`instance_double(Faraday::Connection)` and sets expectations on `.get` / `.post` / `.put`
/ `.delete`. There are no VCR cassettes checked in yet (`spec/fixtures/vcr_cassettes` is
empty); VCR is wired up for future use but not the current pattern. **Follow the existing
`instance_double` pattern for new specs** rather than introducing cassettes unless asked.

No network calls happen during `bundle exec rspec` — don't add specs that hit the real
Loyverse API.

## Architecture

- `lib/loyverse_api.rb` — entry point. Defines `LoyverseApi.configure { |c| ... }` and
  `LoyverseApi.client`, and requires every file below.
- `lib/loyverse_api/configuration.rb` — `Configuration` holds `access_token`,
  `api_base_url` (aliased as `base_url`), `timeout`, `open_timeout`.
- `lib/loyverse_api/client.rb` — `Client`:
  - Includes every `Endpoints::*` module (see below) as mixins.
  - Builds the Faraday connection (`#connection`), lazily memoized, with bearer auth,
    JSON request/response middleware, and `faraday-retry` (max 3 retries on
    429/500/502/503/504).
  - Exposes low-level `get`/`post`/`put`/`delete`, which endpoint methods call.
  - `handle_response` maps HTTP status codes to the exception classes in `errors.rb`.
  - `format_time` normalizes `String`/`Time`/`Date` inputs into the ISO 8601 format the
    Loyverse API expects.
- `lib/loyverse_api/endpoints/*.rb` — one module per API resource (`Items`, `Categories`,
  `Inventory`, `Receipts`, `Webhooks`, `Customers`, `Discounts`, `Employees`,
  `Modifiers`). Each module defines instance methods like `list_x`, `get_x`,
  `create_x`, `update_x`, `delete_x` that call `get`/`post`/`put`/`delete` on `self`
  (the `Client`, since these are mixed in) and return the parsed response body.
- `lib/loyverse_api/errors.rb` — `Error` base class (has `code`/`details`) plus
  `AuthenticationError`, `AuthorizationError`, `NotFoundError`, `BadRequestError`,
  `RateLimitError`, `ServerError`, `ApiError`.

### Adding a new endpoint / resource

1. Create `lib/loyverse_api/endpoints/<resource>.rb` with a module
   `LoyverseApi::Endpoints::<Resource>` defining the CRUD methods, following the style
   of an existing file (`discounts.rb` or `modifiers.rb` are good small examples).
2. `require_relative` it in `lib/loyverse_api.rb` and `include` the module in
   `lib/loyverse_api/client.rb`.
3. Add `spec/loyverse_api/endpoints/<resource>_spec.rb` mirroring the
   `instance_double(Faraday::Connection)` pattern used in the other endpoint specs.
4. Document usage in the README.md "Usage" section (each resource has a collapsible
   `<details>` block with examples).
5. Add a `CHANGELOG.md` entry under an `[Unreleased]` or new version heading, and bump
   `lib/loyverse_api/version.rb` if the maintainer wants a release.

## Conventions to follow

- Endpoint methods return the raw parsed JSON body (`Hash`/`Array`), not custom model
  objects — don't introduce a model/entity layer.
- Use `format_time` (private method on `Client`) wherever a timestamp param is accepted,
  so callers can pass `Time`, `Date`, or an ISO 8601 string interchangeably.
- Keep `Configuration` flat and simple — no environment-variable auto-loading inside the
  gem itself; that's left to the consuming app (or `.env` in dev/test here).
- Don't add a dependency on Rails, ActiveSupport, or any web framework — this gem must
  stay usable from any Ruby app.

## Manual / exploratory testing

`examples/basic_usage.rb`, `examples/create_item.rb`, and `examples/webhook_server.rb`
show real end-to-end usage against the live API using `LOYVERSE_ACCESS_TOKEN` from
`.env`. `examples/receipt_response_sample.json` is a sample raw API response for
reference (see `examples/README.md` for a field-by-field breakdown). Running these
example scripts will make real HTTP requests — only do so with a valid token and be
aware it can create/modify real data in whatever Loyverse account the token belongs to.

## Docs to check before changing endpoint behavior

- Loyverse API reference: https://developer.loyverse.com/docs/
- `README.md` in this repo — user-facing usage examples per resource; keep it in sync
  with any client method signature changes.
- `CHANGELOG.md` — update when behavior changes.
