#!/usr/bin/env ruby

# Script to add new files to Xcode project
require 'xcodeproj'

project_path = File.expand_path('../../Psychosis/Psychosis.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'Psychosis' }
unless target
  puts "Error: Could not find 'Psychosis' target"
  exit 1
end

# New files to add
files_to_add = [
  'Core/Services/ServerPresets.swift',
  'Core/Services/NotificationManager.swift'
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
  actual_path = File.join('../../apps/psychosis-ios/PsychosisApp', file_path)
  
  unless File.exist?(actual_path)
    puts "⚠️  File not found: #{actual_path}"
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
    # Add file reference with correct relative path
    file_ref = group.new_reference("../apps/psychosis-ios/#{full_path}")
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

