# Changelog

All notable changes to `managoat_acp` are documented here. Format:
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow
[SemVer](https://semver.org/). Pre-1.0, a minor bump (`0.x` to `0.y`) may
include breaking changes and says so; patch releases are always safe to take.

Merging a version bump to `main` publishes it to hex; a PR that changes what
the package ships without a bump fails the release gate.

## [Unreleased]

## [0.3.1] - 2026-09-08

Backport of the `:auth` option from 0.4.1, for hosts still on
`managoat_runtimes` 0.3.x (which pins `managoat_acp ~> 0.3.0`).

### Added

- `:auth` on `Peer.start/1`: which advertised method to `authenticate` with.
  `:api_key` (the default, unchanged) picks the first method whose `_meta`
  names an api key; `:none` never authenticates, for an agent whose
  credentials the host has already put where it reads them; a method id
  picks that one when advertised and nothing otherwise. Needed for codex-acp
  with an externally managed ChatGPT `auth.json`, whose api-key method would
  rewrite that file from an env var.

## [0.3.0] - 2026-09-07

### Changed

- Usage reports preserve validated adapter accounting metadata under `"accounting"`.
  This extends the map beyond numeric values. Metadata-only reports have no token
  keys, so consumers must read named counters instead of summing every map value.
  Legacy reports are unchanged. Missing metadata does not imply complete usage.

## [0.2.3] - 2026-09-07

### Fixed

- A variant qualifier on the confirmed model is no longer read as a
  substitution. Claude confirms `opus[1m]` for the 1M-context build of the
  model requested as `claude-opus-5`; dropping separators fused the qualifier
  onto the family name (`opus1m` against `claudeopus5`), so the containment
  comparison added in 0.2.2 still failed the turn on a model that answers
  normally. The qualifier now comes off before the comparison. A qualifier on a
  *different* family (`haiku[1m]` for `claude-opus-5`) still fails, and a
  confirmation that is nothing but a qualifier (`[1m]`) still fails
  (BinaryBourbon/fountain#1668).

## [0.2.2] - 2026-09-06

### Fixed

- A runtime confirming a model in its own canonical designation is no longer
  read as a substitution. Claude's adapter accepts `claude-opus-5` and confirms
  `opus`, and `claude-sonnet-5` and confirms `sonnet`; the strict equality
  introduced with explicit model selection (#4) failed those turns before any
  prompt was written, which took every claude agent on an instance offline.
  Codex echoes the requested id verbatim and was unaffected, which is why the
  defect reached production looking like a model-catalog problem. Designations
  are now compared with case and separators normalised, and one containing the
  other counts as agreement. An outright refusal still fails the turn, and a
  confirmation naming a different model (`claude-haiku-4-5` for a requested
  `claude-opus-5`) still fails, which is the case the check exists for.

## [0.2.1] - 2026-09-06

### Fixed

- Drop updates naming another session before persistence and replay accounting.
  Cancel foreign permission requests before consulting the peer's policy, so
  another session cannot inherit its auto-allow grants (#5).

## [0.2.0]

### Changed

- **Breaking:** explicit model selection now fails before inference when rejected,
  unsupported, or confirmed as a different model. There is no default fallback.
- `Peer.prompt/4` applies changed models on an existing session. Each prompt
  reports requested/effective model and whether the evidence is runtime metadata
  or an acknowledgement. Replaces the nonfatal `model_rejected` report.

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
