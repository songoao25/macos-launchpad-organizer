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

def inspect_page(page, label)
  page = expect_hash(page, label)
  number = page["number"]
  fail_schema("#{label}.number must be a positive integer") unless number.is_a?(Integer) && number.positive?
  [page, expect_array(page["items"] || [], "#{label}.items")]
end

def inspect_layout(document)
  document = expect_hash(document, "document")
  apps = expect_hash(document["apps"], "apps")
  root_pages = expect_array(apps["pages"], "apps.pages")
  result = { apps: [], folders: [], root_apps: [], empty_folders: [], empty_folder_pages: [], page_count: root_pages.length }

  root_pages.each_with_index do |page, page_index|
    _, items = inspect_page(page, "apps.pages[#{page_index}]")
    items.each_with_index do |item, item_index|
      item_label = "apps.pages[#{page_index}].items[#{item_index}]"
      if item.is_a?(String)
        fail_schema("#{item_label} must not be empty") if item.strip.empty?
        result[:apps] << item
        result[:root_apps] << item
        next
      end

      item = expect_hash(item, item_label)
      name = item["folder"]
      fail_schema("#{item_label}.folder must be a non-empty string") unless name.is_a?(String) && !name.strip.empty?
      pages = expect_array(item["pages"], "#{item_label}.pages")
      fail_schema("#{item_label}.pages must contain at least one page") if pages.empty?
      result[:folders] << name
      folder_app_count = 0

      pages.each_with_index do |folder_page, folder_page_index|
        _, folder_items = inspect_page(folder_page, "#{item_label}.pages[#{folder_page_index}]")
        if folder_items.empty?
          result[:empty_folder_pages] << "#{name} (page #{folder_page_index + 1})"
          next
        end

        folder_items.each_with_index do |folder_item, folder_item_index|
          folder_item_label = "#{item_label}.pages[#{folder_page_index}].items[#{folder_item_index}]"
          fail_schema("#{folder_item_label} must be a non-empty application name string; nested folders are not supported") unless folder_item.is_a?(String) && !folder_item.strip.empty?
          result[:apps] << folder_item
          folder_app_count += 1
        end
      end

      result[:empty_folders] << name if folder_app_count.zero?
    end
  end
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
baseline_folder_duplicates = duplicate_names(baseline[:folders])
target_folder_duplicates = duplicate_names(target[:folders])
missing = baseline[:apps] - target[:apps]
unexpected = target[:apps] - baseline[:apps]

errors << "baseline contains duplicate app names: #{baseline_duplicates.join(', ')}" unless baseline_duplicates.empty?
errors << "target contains duplicate app names: #{target_duplicates.join(', ')}" unless target_duplicates.empty?
errors << "baseline contains duplicate folder names: #{baseline_folder_duplicates.join(', ')}" unless baseline_folder_duplicates.empty?
errors << "target contains duplicate folder names: #{target_folder_duplicates.join(', ')}" unless target_folder_duplicates.empty?
errors << "missing apps: #{missing.join(', ')}" unless missing.empty?
errors << "unexpected apps: #{unexpected.join(', ')}" unless unexpected.empty?
errors << "root-level apps: #{target[:root_apps].join(', ')}" if options[:folders_only] && !target[:root_apps].empty?
errors << "expected one page, found #{target[:page_count]}" if options[:one_page] && target[:page_count] != 1
errors << "empty folders: #{target[:empty_folders].join(', ')}" if options[:no_empty_folders] && !target[:empty_folders].empty?
errors << "empty folder pages: #{target[:empty_folder_pages].join(', ')}" if options[:no_empty_folders] && !target[:empty_folder_pages].empty?

if errors.empty?
  puts "PASS pages=#{target[:page_count]} folders=#{target[:folders].length} apps=#{target[:apps].length}"
  exit 0
end

warn "FAIL"
errors.each { |error| warn "- #{error}" }
exit 1
