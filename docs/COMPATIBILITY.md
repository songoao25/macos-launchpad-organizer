# Compatibility policy

This project supports **planning and validating** a native Launchpad layout on macOS releases where Launchpad exists. The validator itself is file-based and does not modify macOS.

Applying a layout requires a separate writer because Apple does not provide a public Launchpad-layout API. A writer must be evaluated on the exact macOS release before use.

| Component | Status |
| --- | --- |
| Skill instructions and layout validator | macOS-independent Ruby workflow |
| Native Launchpad organization | Only on macOS versions that still include Launchpad |
| macOS Tahoe 26+ native Launchpad | Unsupported: the feature no longer exists |
| `lporg` writer | Archived third-party migration utility; do not treat as a supported dependency |

When a writer emits a warning, returns nonzero, or produces an unexpected folder, stop and recover from the standalone backup. Do not run a second write as a workaround.
