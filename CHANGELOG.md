# Changelog

All notable changes to this project are documented here.

## 0.1.6 - 2026-08-23

- Clarified that the validation hardening shipped in `0.1.5`; no `0.1.4` release was published.

## 0.1.5 - 2026-08-23

- Fixed release checksum files so downloaded archives can be verified from the same directory.
- Reject nested folders and duplicate folder names in writer-compatible layouts.
- Validate page numbers and reject empty folder pages, YAML aliases, and malformed layout structures.
- Added regression coverage for the expanded validation contract.
- Added CodeQL, Dependabot, code ownership, stronger privacy ignores, release checksums, and clearer scope language.

## 0.1.3 - 2026-08-23

- Updated the pinned GitHub Actions checkout dependency to the Node 24 runtime.

## 0.1.2 - 2026-08-23

- Restored the tracked GitHub Actions workflow after tightening YAML privacy ignores.

## 0.1.1 - 2026-08-23

- Added release, license, activity, and skill badges to the README.
- Added repository metadata and topic guidance for GitHub publication.

## 0.1.0 - 2026-08-23

- Initial public release of the native Launchpad organization skill.
- Added a safe YAML layout validator and positive/negative fixture suite.
- Added compatibility, release, privacy, and contributor guidance.
