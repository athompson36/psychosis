#!/usr/bin/env ruby

# Script to add ServerFormView to Xcode project
require 'xcodeproj'

project_path = File.expand_path('../../Psychosis/Psychosis.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

target = project.targets.find { |t| t.name == 'Psychosis' }
unless target
  puts "Error: Could not find 'Psychosis' target"
  exit 1
end

file_path = 'Features/MainPane/ServerFormView.swift'
full_path = File.join('../../apps/hub-ios/HubApp', file_path)

unless File.exist?(full_path)
  puts "Error: File not found: #{full_path}"
  exit 1
end

# Get or create MainPane group
main_group = project.main_group
features_group = main_group.children.find { |c| c.display_name == 'Features' && c.is_a?(Xcodeproj::Project::Object::PBXGroup) } || main_group.new_group('Features')
main_pane_group = features_group.children.find { |c| c.display_name == 'MainPane' && c.is_a?(Xcodeproj::Project::Object::PBXGroup) } || features_group.new_group('MainPane')

# Check if file already exists
existing_file = main_pane_group.children.find { |c| c.display_name == 'ServerFormView.swift' && c.is_a?(Xcodeproj::Project::Object::PBXFileReference) }

if existing_file
  puts "⏭️  Already in project: #{file_path}"
  file_ref = existing_file
else
  # Add file reference
  file_ref = main_pane_group.new_reference("../apps/hub-ios/HubApp/#{file_path}")
  puts "✅ Added: #{file_path}"
end

# Add to target's compile sources
unless target.source_build_phase.files.find { |f| f.file_ref == file_ref }
  target.add_file_references([file_ref])
  puts "   → Added to target compile sources"
end

project.save
puts "✨ Project saved successfully!"

