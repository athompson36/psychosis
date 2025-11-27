#!/usr/bin/env ruby

# Script to add files to Xcode project via command line
# Usage: ruby add_files_to_xcode.rb

require 'xcodeproj'

# Try to find the project file
project_paths = [
  'Psychosis.xcodeproj',
  '../Psychosis/Psychosis.xcodeproj',
  '../../Psychosis/Psychosis.xcodeproj'
]

project_path = nil
project_paths.each do |path|
  full_path = File.expand_path(path)
  if File.exist?(full_path)
    project_path = full_path
    break
  end
end

unless project_path
  puts "Error: Could not find Xcode project file"
  puts "Searched in:"
  project_paths.each { |p| puts "  - #{File.expand_path(p)}" }
  exit 1
end

puts "Using project: #{project_path}"
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'Psychosis' }
unless target
  puts "Error: Could not find 'Psychosis' target"
  exit 1
end

# Files to add (relative to PsychosisApp/)
files_to_add = [
  'Core/Services/ConnectionHistoryManager.swift',
  'Core/Services/ConnectionQualityMonitor.swift',
  'Core/UI/WebViewWrapper.swift',
  'Core/Utilities/ScreenshotManager.swift',
  'Features/RemoteDesktop/RemoteDesktopToolbar.swift',
  'Features/RemoteDesktop/VirtualKeyboardView.swift',
  'Features/Settings/RecentConnectionsView.swift'
]

# Get or create groups
def get_or_create_group(project, path_parts)
  current_group = project.main_group
  path_parts.each do |part|
    existing = current_group.children.find { |c| c.display_name == part && c.is_a?(Xcodeproj::Project::Object::PBXGroup) }
    if existing
      current_group = existing
    else
      new_group = current_group.new_group(part)
      current_group = new_group
    end
  end
  current_group
end

added_count = 0
skipped_count = 0

files_to_add.each do |file_path|
  full_path = File.join('PsychosisApp', file_path)
  
  unless File.exist?(full_path)
    puts "⚠️  File not found: #{full_path}"
    skipped_count += 1
    next
  end
  
  # Split path into parts
  path_parts = file_path.split('/')
  file_name = path_parts.pop
  group_path = path_parts
  
  # Get or create the group
  group = get_or_create_group(project, group_path)
  
  # Check if file already exists in project
  existing_file = group.children.find { |c| c.display_name == file_name && c.is_a?(Xcodeproj::Project::Object::PBXFileReference) }
  
  if existing_file
    puts "⏭️  Already in project: #{file_path}"
    file_ref = existing_file
  else
    # Add file reference
    file_ref = group.new_reference(full_path)
    puts "✅ Added: #{file_path}"
    added_count += 1
  end
  
  # Add to target's compile sources
  unless target.source_build_phase.files.find { |f| f.file_ref == file_ref }
    target.add_file_references([file_ref])
    puts "   → Added to target compile sources"
  end
end

# Save project
project.save

puts "\n📊 Summary:"
puts "   ✅ Added: #{added_count} files"
puts "   ⏭️  Skipped: #{skipped_count} files"
puts "\n✨ Project saved successfully!"

