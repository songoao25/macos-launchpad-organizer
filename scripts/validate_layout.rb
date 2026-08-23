#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "yaml"

MAX_LAYOUT_BYTES = 5 * 1024 * 1024

options = { folders_only: false, one_page: false, no_empty_folders: false }
OptionParser.new do |parser|
  parser.banner = "Usage: validate_layout.rb --baseline before.yml --target after.yml [options]"
  parser.on("--baseline PATH", "Exported current Launchpad layout") { |value| options[:baseline] = value }
  parser.on("--target PATH", "Proposed or post-write layout") { |value| options[:target] = value }
  parser.on("--folders-only", "Require no app icons at the root") { options[:folders_only] = true }
  parser.on("--one-page", "Require exactly one root Launchpad page") { options[:one_page] = true }
  parser.on("--no-empty-folders", "Reject folders without app items") { options[:no_empty_folders] = true }
end.parse!

abort "ERROR: --baseline is required" unless options[:baseline]
abort "ERROR: --target is required" unless options[:target]

def fail_schema(message)
  abort "ERROR: invalid layout: #{message}"
end

def load_layout(path)
  fail_schema("file not found: #{path}") unless File.file?(path)
  fail_schema("file is larger than #{MAX_LAYOUT_BYTES} bytes: #{path}") if File.size(path) > MAX_LAYOUT_BYTES

  source = File.open(path, "r:bom|utf-8", &:read)
  YAML.safe_load(source, permitted_classes: [], permitted_symbols: [], aliases: false)
rescue Psych::Exception => error
  fail_schema("cannot parse #{path}: #{error.message}")
rescue ArgumentError
  # Ruby 2.6's safe_load uses positional parameters.
  YAML.safe_load(source, [], [], false)
end

def expect_hash(value, label)
  fail_schema("#{label} must be a mapping") unless value.is_a?(Hash)
  value
end

def expect_array(value, label)
  fail_schema("#{label} must be a list") unless value.is_a?(Array)
  value
end

def inspect_layout(document)
  document = expect_hash(document, "document")
  apps = expect_hash(document["apps"], "apps")
  root_pages = expect_array(apps["pages"], "apps.pages")
  result = { apps: [], folders: [], root_apps: [], empty_folders: [], page_count: root_pages.length }

  walk_page = nil
  walk_page = lambda do |page, at_root, label|
    page = expect_hash(page, label)
    items = expect_array(page["items"] || [], "#{label}.items")

    items.each_with_index do |item, index|
      item_label = "#{label}.items[#{index}]"
      if item.is_a?(String)
        fail_schema("#{item_label} must not be empty") if item.strip.empty?
        result[:apps] << item
        result[:root_apps] << item if at_root
        next
      end

      item = expect_hash(item, item_label)
      name = item["folder"]
      fail_schema("#{item_label}.folder must be a non-empty string") unless name.is_a?(String) && !name.strip.empty?
      pages = expect_array(item["pages"], "#{item_label}.pages")
      fail_schema("#{item_label}.pages must contain at least one page") if pages.empty?
      result[:folders] << name
      app_count_before = result[:apps].length
      pages.each_with_index { |folder_page, page_index| walk_page.call(folder_page, false, "#{item_label}.pages[#{page_index}]") }
      result[:empty_folders] << name if result[:apps].length == app_count_before
    end
  end

  root_pages.each_with_index { |page, index| walk_page.call(page, true, "apps.pages[#{index}]") }
  result
end

def duplicate_names(items)
  items.group_by(&:itself).select { |_, duplicates| duplicates.length > 1 }.keys
end

baseline = inspect_layout(load_layout(options[:baseline]))
target = inspect_layout(load_layout(options[:target]))
errors = []

baseline_duplicates = duplicate_names(baseline[:apps])
target_duplicates = duplicate_names(target[:apps])
missing = baseline[:apps] - target[:apps]
unexpected = target[:apps] - baseline[:apps]

errors << "baseline contains duplicate app names: #{baseline_duplicates.join(', ')}" unless baseline_duplicates.empty?
errors << "target contains duplicate app names: #{target_duplicates.join(', ')}" unless target_duplicates.empty?
errors << "missing apps: #{missing.join(', ')}" unless missing.empty?
errors << "unexpected apps: #{unexpected.join(', ')}" unless unexpected.empty?
errors << "root-level apps: #{target[:root_apps].join(', ')}" if options[:folders_only] && !target[:root_apps].empty?
errors << "expected one page, found #{target[:page_count]}" if options[:one_page] && target[:page_count] != 1
errors << "empty folders: #{target[:empty_folders].join(', ')}" if options[:no_empty_folders] && !target[:empty_folders].empty?

if errors.empty?
  puts "PASS pages=#{target[:page_count]} folders=#{target[:folders].length} apps=#{target[:apps].length}"
  exit 0
end

warn "FAIL"
errors.each { |error| warn "- #{error}" }
exit 1
