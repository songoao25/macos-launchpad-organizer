# macOS Launchpad Organizer

[![Validate](https://github.com/songoao25/macos-launchpad-organizer/actions/workflows/validate.yml/badge.svg)](https://github.com/songoao25/macos-launchpad-organizer/actions/workflows/validate.yml)
[![Release](https://img.shields.io/github/v/release/songoao25/macos-launchpad-organizer?display_name=tag)](https://github.com/songoao25/macos-launchpad-organizer/releases)
[![License](https://img.shields.io/github/license/songoao25/macos-launchpad-organizer)](LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/songoao25/macos-launchpad-organizer)](https://github.com/songoao25/macos-launchpad-organizer/commits/main)
[![Codex skill](https://img.shields.io/badge/Codex-skill-412991)](SKILL.md)

A Codex skill for planning and validating a safe, batch organization of the **native macOS Launchpad**. It helps an agent inventory the current layout, research unfamiliar apps, propose natural folder names, and verify that a reviewed layout has no omissions or duplicates.

## Scope

- Keeps the native macOS Launchpad. It is **not** a replacement launcher.
- Requires explicit user approval before any external writer changes the native layout.
- Does not bundle or endorse a private-database writer. The layout validator is read-only.
- Does not support organizing native Launchpad on macOS Tahoe 26+, where Apple removed the feature.

See [compatibility policy](docs/COMPATIBILITY.md) and the [writer contract](docs/WRITER-CONTRACT.md) before attempting a write.

## Highlights

- Plans natural, purpose-specific folders instead of generic auto-categories.
- Keeps an exported layout as the source of truth, so no visible app is silently lost.
- Checks omissions, duplicates, root-level icons, page count, and empty folders before a writer is used.
- Keeps the private-database writer as an explicit trust boundary rather than hiding the risk.

## Why a skill instead of a drag-and-drop tutorial?

Manual organization is slow and error-prone when a Launchpad contains many applications. This skill gives an agent a cautious workflow:

1. Export a standalone backup using a writer compatible with the current macOS release.
2. Read every app in that export—not merely the apps found on disk.
3. Use bundle metadata and authoritative product pages for unfamiliar software.
4. Present a complete, human-readable folder plan for approval.
5. Validate the proposed layout before and after a separate writer applies it.

The skill distinguishes `AI`, `剪辑`, `看视频`, `听音乐`, and `截图和录屏` where the user's applications warrant that level of detail; it does not settle for generic categories by default.

## Install in Codex

Clone the repository, then copy the project folder into your Codex skills directory:

```sh
git clone https://github.com/songoao25/macos-launchpad-organizer.git
cp -R macos-launchpad-organizer ~/.codex/skills/
```

Restart or refresh Codex if the skill does not appear immediately. Invoke it with:

```text
Use $macos-launchpad-organizer to audit and organize my native macOS Launchpad.
```

## Project layout

| Path | Purpose |
| --- | --- |
| `SKILL.md` | Instructions Codex loads for native Launchpad organization requests. |
| `scripts/validate_layout.rb` | Read-only YAML plan and result validator. |
| `tests/` | Public positive and negative validator fixtures. |
| `docs/` | Compatibility, external writer, and release guidance. |

## Validate a layout

The layout validator accepts the common YAML shape used by Launchpad exporters such as `lporg`. It compares a baseline export with a target layout, but never writes to macOS.

```sh
ruby scripts/validate_layout.rb \
  --baseline path/to/launchpad-before.yml \
  --target path/to/launchpad-organized.yml \
  --one-page --folders-only --no-empty-folders
```

It rejects:

- missing or unexpected apps;
- duplicate names in either the baseline or target;
- root-level apps when a folders-only layout is requested;
- multiple root pages when one page is requested;
- empty folders; and
- malformed or oversized YAML input.

## Test

Run the public fixture suite:

```sh
ruby tests/run.rb
```

It covers valid layouts plus duplicate, missing, root-level, multi-page, empty-folder, and malformed-layout failure paths.

## Privacy and safety

Never commit real exports, backups, SQLite databases, WAL/SHM files, screenshots, logs, account identifiers, or filesystem paths. The `.gitignore` blocks common layout and database files; the only YAML files intentionally tracked are skill metadata and public test fixtures.

Do not claim that a Dock restart proves full-reboot persistence. Do not retry a private-database write merely because a writer created some folders but emitted a warning or a nonzero exit.

## Publishing a release

Follow the [release checklist](docs/RELEASING.md) and enable private vulnerability reporting in repository settings. `scripts/package_release.sh X.Y.Z` creates a clean ZIP from a committed tree with the correct top-level folder.

## Contributing and security

- [Contributing guide](CONTRIBUTING.md)
- [Security policy](SECURITY.md)
- [Changelog](CHANGELOG.md)

## License

[MIT](LICENSE)
