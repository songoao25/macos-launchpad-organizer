# Writer contract

The skill deliberately does not bundle a private-database writer. A writer is acceptable only if it can meet all of these conditions on the current macOS release:

1. Export the current native layout without modification.
2. Apply a reviewed YAML layout without touching unrelated Dock settings or deleting applications.
3. Create a standalone backup before mutation and document an exact restore operation.
4. Return nonzero on failure and preserve enough evidence to diagnose the result.
5. Allow an independent post-write export, so `scripts/validate_layout.rb` can compare the result with the pre-write export.

Run the validator before and after a writer invocation:

```sh
ruby scripts/validate_layout.rb \
  --baseline backups/launchpad-before.yml \
  --target layouts/reviewed.yml \
  --one-page --folders-only --no-empty-folders
```

Treat the writer as a separate trust boundary. Never publish a real export or database as a bug report or test fixture.
