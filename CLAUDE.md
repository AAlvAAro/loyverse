# CLAUDE.md

@AGENTS.md

The file above (`AGENTS.md`) is the canonical guide for working in this repo — what the
gem does, how to set it up, how to run tests, and the architecture/conventions to
follow when adding or changing endpoints. Read it before making changes.

A couple of Claude-Code-specific notes on top of that:

- Prefer `bundle exec rspec <path>` for fast, targeted runs while iterating; run the
  full `bundle exec rspec` before considering a change done.
- This repo has no `.env` committed (only `.env.sample`) — never commit real Loyverse
  access tokens, and don't hardcode them in specs or examples.
- Endpoint specs stub `client.connection` directly; there's no live-API test mode, so
  there's nothing to run against a server for `/verify`-style checks beyond the test
  suite itself.
