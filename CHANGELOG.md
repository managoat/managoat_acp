# Changelog

All notable changes to `managoat_acp` are documented here. Format:
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[SemVer](https://semver.org/). Pre-1.0, a minor bump (`0.x` to `0.y`) may
include breaking changes and says so; patch releases are always safe to take.

Merging a version bump to `main` publishes it to hex; a PR that changes what
the package ships without a bump fails the release gate.

## [Unreleased]

## [0.1.2] - 2026-09-03

### Changed

- Expanded behavior-focused coverage for transcript blocks, policy helpers,
  protocol classification, tracing, and the shipped scripted agent, and raised
  the coverage gate from 90% to 95%.

## [0.1.1] - 2026-09-03

### Fixed

- `Usage.from_prompt_result/1` now reads gemini-cli's tokens. gemini leaves
  the protocol's `usage` field empty and reports the turn under a vendor
  extension at `_meta.quota.token_count`, snake-cased
  (google-gemini/gemini-cli#24280, closed with no plans to add the standard
  fields), so every gemini turn returned `nil` — a host billing from this
  figure billed nothing at all (BinaryBourbon/fountain#1459). The new
  `Usage.from_meta_quota/1` reads that shape; the protocol's own `usage`
  still wins where both are present.

## [0.1.0] - 2026-09-02

### Added

- Extracted from Fountain (BinaryBourbon/fountain#1358).
