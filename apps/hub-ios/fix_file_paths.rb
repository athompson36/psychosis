#!/usr/bin/env ruby

# Script to fix file paths in Xcode project
require 'xcodeproj'

project_path = File.expand_path('../../Psychosis/Psychosis.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'Psychosis' }
unless target
  puts "Error: Could not find 'Psychosis' target"
  exit 1
end

# Files that need path fixing
files_to_fix = [
  'ConnectionHistoryManager.swift',
  'ConnectionQualityMonitor.swift',
  'WebViewWrapper.swift',
  'ScreenshotManager.swift',
  'RemoteDesktopToolbar.swift',
  'VirtualKeyboardView.swift',
  'RecentConnectionsView.swift'
]

puts "Fixing file paths in Xcode project..."
puts "Project location: #{project_path}"
puts "Correct base path: ../../apps/hub-ios/HubApp\n"

fixed_count = 0

# Get all file references
all_file_refs = project.files.select { |f| f.is_a?(Xcodeproj::Project::Object::PBXFileReference) }

files_to_fix.each do |filename|
  # Find references to this file
  matching_refs = all_file_refs.select do |ref|
    ref.path && (ref.path.end_with?(filename) || ref.path.include?(filename))
  end
  
  matching_refs.each do |ref|
    current_path = ref.path
    
    # Check if path is wrong (starts with HubApp/ but should be ../apps/hub-ios/HubApp/)
    if current_path.start_with?('HubApp/')
      # Calculate correct relative path from project location
      # Project is at: Psychosis/Psychosis.xcodeproj
      # Files are at: apps/hub-ios/HubApp/...
      # Relative path from Psychosis/: ../apps/hub-ios/HubApp/...
      
      correct_path = "../apps/hub-ios/#{current_path}"
      
      # Verify file exists at correct path
      project_dir = File.dirname(project_path)
      full_correct_path = File.expand_path(correct_path, project_dir)
      
      if File.exist?(full_correct_path)
        puts "✅ Fixing: #{current_path}"
        puts "   → #{correct_path}"
        ref.path = correct_path
        fixed_count += 1
      else
        puts "⚠️  File not found at: #{full_correct_path}"
        puts "   Current path: #{current_path}"
      end
    elsif current_path.start_with?('../apps/hub-ios/HubApp/')
      puts "✅ Already correct: #{current_path}"
    else
      # Try to find the correct path
      correct_path = "../apps/hub-ios/HubApp/#{current_path.split('/').last}"
      project_dir = File.dirname(project_path)
      full_correct_path = File.expand_path(correct_path, project_dir)
      
      if File.exist?(full_correct_path)
        puts "✅ Fixing: #{current_path}"
        puts "   → #{correct_path}"
        ref.path = correct_path
        fixed_count += 1
      else
        puts "⚠️  Could not determine correct path for: #{current_path}"
      end
    end
  end
end

project.save

puts "\n📊 Summary:"
puts "   ✅ Fixed: #{fixed_count} file paths"
puts "\n✨ Project saved successfully!"

