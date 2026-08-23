# Contributing

Thank you for improving this project.

## Ground rules

- Keep the project focused on organizing the native Launchpad. Do not turn it into a replacement launcher or uninstaller.
- Do not add sample exports, database files, screenshots, logs, account names, or private paths.
- Any change that relaxes a safety check needs a documented reason and negative test coverage.
- Do not claim support for a macOS version unless the workflow has been tested on that release.

## Before opening a pull request

```sh
ruby tests/run.rb
```

Describe the macOS version and writer used for any compatibility claim. Do not attach a real Launchpad database or personal app inventory to an issue or pull request.
