#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"

root = File.expand_path("..", __dir__)
script = File.join(root, "scripts", "validate_layout.rb")
fixtures = File.join(__dir__, "fixtures")
flags = ["--one-page", "--folders-only", "--no-empty-folders"]

cases = [
  ["valid layout", "before.yml", "after.yml", true],
  ["baseline duplicate", "before-duplicate.yml", "after.yml", false],
  ["missing app", "before.yml", "after-missing.yml", false],
  ["target duplicate", "before.yml", "after-duplicate.yml", false],
  ["root app", "before.yml", "after-root.yml", false],
  ["multiple pages", "before.yml", "after-two-pages.yml", false],
  ["empty folder", "before.yml", "after-empty-folder.yml", false],
  ["malformed layout", "malformed.yml", "after.yml", false]
]

failures = []
cases.each do |name, baseline, target, expected_success|
  command = ["ruby", script, "--baseline", File.join(fixtures, baseline), "--target", File.join(fixtures, target), *flags]
  stdout, stderr, status = Open3.capture3(*command)
  passed = status.success? == expected_success
  puts "#{passed ? 'PASS' : 'FAIL'} #{name}"
  failures << "#{name}: #{stdout}#{stderr}" unless passed
end

abort "\n#{failures.join("\n")}" unless failures.empty?
