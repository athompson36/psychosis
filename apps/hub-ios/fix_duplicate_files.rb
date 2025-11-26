#!/usr/bin/env ruby

# Script to remove duplicate file references from Xcode project
require 'xcodeproj'

project_path = File.expand_path('../../Psychosis/Psychosis.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.find { |t| t.name == 'Psychosis' }
unless target
  puts "Error: Could not find 'Psychosis' target"
  exit 1
end

# Files that might be duplicated
files_to_check = [
  'ConnectionHistoryManager.swift',
  'ConnectionQualityMonitor.swift',
  'WebViewWrapper.swift',
  'ScreenshotManager.swift',
  'RemoteDesktopToolbar.swift',
  'VirtualKeyboardView.swift',
  'RecentConnectionsView.swift'
]

puts "Cleaning up duplicate file references..."

removed_count = 0

# Get all file references in the project
all_file_refs = project.files.select { |f| f.is_a?(Xcodeproj::Project::Object::PBXFileReference) }

files_to_check.each do |filename|
  # Find all references to this file
  matching_refs = all_file_refs.select do |ref|
    ref.path && (ref.path.end_with?(filename) || ref.path.end_with?("/#{filename}"))
  end
  
  if matching_refs.length > 1
    puts "\n⚠️  Found #{matching_refs.length} references to #{filename}:"
    matching_refs.each_with_index do |ref, idx|
      puts "   #{idx + 1}. #{ref.path} (in group: #{ref.parent&.display_name || 'unknown'})"
    end
    
    # Keep the one with the full HubApp/ path, remove others
    full_path_ref = matching_refs.find { |r| r.path&.start_with?('HubApp/') }
    short_path_refs = matching_refs.reject { |r| r.path&.start_with?('HubApp/') }
    
    if full_path_ref
      puts "   ✅ Keeping: #{full_path_ref.path}"
      
      short_path_refs.each do |ref|
        puts "   ❌ Removing: #{ref.path}"
        
        # Remove from target's compile sources
        target.source_build_phase.files.each do |build_file|
          if build_file.file_ref == ref
            target.source_build_phase.remove_file_reference(ref)
            puts "      → Removed from compile sources"
          end
        end
        
        # Remove from parent group
        ref.remove_from_project
        removed_count += 1
      end
    else
      # If no full path ref, keep the first one and remove others
      puts "   ✅ Keeping: #{matching_refs.first.path}"
      matching_refs[1..-1].each do |ref|
        puts "   ❌ Removing: #{ref.path}"
        target.source_build_phase.files.each do |build_file|
          if build_file.file_ref == ref
            target.source_build_phase.remove_file_reference(ref)
          end
        end
        ref.remove_from_project
        removed_count += 1
      end
    end
  end
end

# Also check for VirtualKeyboardView and RemoteDesktopToolbar specifically
['VirtualKeyboardView.swift', 'RemoteDesktopToolbar.swift'].each do |filename|
  refs = all_file_refs.select { |r| r.path&.end_with?(filename) }
  if refs.empty?
    puts "\n⚠️  #{filename} not found in project - may need to be added"
  elsif refs.length == 1
    puts "\n✅ #{filename} found once: #{refs.first.path}"
  end
end

project.save

puts "\n📊 Summary:"
puts "   ❌ Removed: #{removed_count} duplicate file references"
puts "\n✨ Project cleaned and saved!"

