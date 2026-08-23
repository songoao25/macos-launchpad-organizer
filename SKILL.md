---
name: macos-launchpad-organizer
description: Safely audit and batch-organize the native macOS Launchpad into user-named folders, with backups, classification review, and post-write verification. Use only for the native Launchpad, not replacement launchers.
---

# Native macOS Launchpad organizer

Use this skill to plan and apply a reviewable Launchpad cleanup without manually dragging every icon. Preserve the native macOS Launchpad; do not build or install a replacement launcher unless separately requested.

## Compatibility and boundaries

- Identify the installed macOS version first. On macOS Tahoe (26+) Apple removed native Launchpad, so explain the limitation and do not silently substitute a launcher.
- Apple exposes no public API for editing Launchpad folders or pages. Tools that write the layout use private, version-sensitive local data. Never promise permanent compatibility or zero-risk behavior after a macOS upgrade.
- Read the current Launchpad layout before planning. That export—not a scan of every `.app` on disk—is the source of truth for what must be organized.
- Do not delete apps, reset Launchpad, or edit unrelated Dock items as part of cleanup.

## Workflow

1. Export a timestamped backup to a user-accessible location before changing anything. State the exact restore file.
2. List every exported app. Inspect local bundle metadata; for unfamiliar apps, verify purpose from an authoritative source. Keep distinct activities distinct when useful: image editing, screenshot/recording, video editing, video viewing, music listening, and audio tools should not be collapsed by default.
3. Propose short, natural folder names such as `AI`, `剪辑`, `看视频`, `听音乐`, and `截图和录屏`. Avoid report-like labels and do not invent a category for unclear software.
4. Show the complete proposed mapping and receive user approval immediately before writing the native layout.
5. Validate the target against the backup. Require no missing apps, no unexpected apps, and no duplicate placement. Use `scripts/validate_layout.rb` when its YAML layout format matches the files.
6. Apply the reviewed layout once, restart Dock only if the writer requires it, then re-export and validate the persisted result.
7. Report pages, folders, root-level apps, empty folders, and the exact recovery action. A Dock restart and database re-read do not prove a full computer reboot; say so unless an actual reboot test was performed.

## Private-database writers

An archived writer such as `lporg` can be used as a migration utility only after compatibility is established for the current macOS version.

- Save a standalone backup before loading a new config; do not rely solely on a writer's automatic-backup flag.
- Treat warnings and nonzero exits as failures to investigate. Do not declare success solely because the command created folders.
- If an empty `Other`/`其他` folder appears, inspect the re-export first. Remove it only after confirming that it and its holding page are empty, a fresh backup exists, and the removal can be done transactionally. Re-export after removal.

## Agent-assisted classification

- Explain the basis of each recommendation and keep the user in control of the final names and grouping.
- Put only confirmed app names in the target layout. Ask about ambiguous apps rather than guessing, unless the user accepts a temporary catch-all folder.
- Retain the editable backup and target layout file for later revisions and recovery.
