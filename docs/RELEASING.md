# Release checklist

1. Run `ruby tests/run.rb`.
2. Review `git status --short`; it must not include exports, databases, backups, screenshots, logs, or personal paths.
3. Review the archive contents after packaging. The ZIP must contain one top-level `macos-launchpad-organizer/` directory, not a local `outputs/` prefix.
4. Update `CHANGELOG.md`, choose a semantic version tag, and create a GitHub release from that tag.
5. Enable private vulnerability reporting in the repository settings before relying on `SECURITY.md`.

This project uses semantic versioning while it remains below `1.0.0`: patch releases fix validation or documentation defects; minor releases add backward-compatible capability; a major release may change the layout contract.

Package a clean committed tree with:

```sh
scripts/package_release.sh X.Y.Z
```

Upload both the ZIP and its adjacent `.sha256` checksum file to the GitHub Release.
