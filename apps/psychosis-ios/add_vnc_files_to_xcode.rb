#!/usr/bin/env ruby
# Add new VNC client files to Xcode project
# Run from project root: ruby apps/psychosis-ios/add_vnc_files_to_xcode.rb

require 'xcodeproj'

# Find project path
script_dir = File.dirname(File.expand_path(__FILE__))
project_path = File.expand_path('../../Psychosis/Psychosis.xcodeproj', script_dir)

unless File.exist?(project_path)
  puts "❌ Xcode project not found at: #{project_path}"
  puts "Please ensure Psychosis.xcodeproj exists"
  exit 1
end

project = Xcodeproj::Project.open(project_path)

# Find the main target
target = project.targets.first
puts "Target: #{target.name}"

# Find the PsychosisApp group (or create it)
main_group = project.main_group
app_group = main_group['Psychosis'] || main_group['PsychosisApp']

if app_group.nil?
  # Try to find it by searching
  app_group = main_group.groups.find { |g| g.name == 'Psychosis' || g.name == 'PsychosisApp' }
end

if app_group.nil?
  puts "❌ Could not find Psychosis/PsychosisApp group"
  exit 1
end

puts "Found group: #{app_group.name}"

# Base path for files
base_path = File.expand_path('PsychosisApp', script_dir)

# Files to add
files_to_add = [
  {
    path: File.join(base_path, 'Core/VNC/VNCConnection.swift'),
    relative_path: '../apps/psychosis-ios/PsychosisApp/Core/VNC/VNCConnection.swift',
    group_path: ['Core', 'VNC'],
    name: 'VNCConnection.swift'
  },
  {
    path: File.join(base_path, 'Core/VNC/VNCFrameBuffer.swift'),
    relative_path: '../apps/psychosis-ios/PsychosisApp/Core/VNC/VNCFrameBuffer.swift',
    group_path: ['Core', 'VNC'],
    name: 'VNCFrameBuffer.swift'
  },
  {
    path: File.join(base_path, 'Core/Services/CursorPaneController.swift'),
    relative_path: '../apps/psychosis-ios/PsychosisApp/Core/Services/CursorPaneController.swift',
    group_path: ['Core', 'Services'],
    name: 'CursorPaneController.swift'
  },
  {
    path: File.join(base_path, 'Features/RemoteDesktop/NativeVNCView.swift'),
    relative_path: '../apps/psychosis-ios/PsychosisApp/Features/RemoteDesktop/NativeVNCView.swift',
    group_path: ['Features', 'RemoteDesktop'],
    name: 'NativeVNCView.swift'
  },
  {
    path: File.join(base_path, 'Features/RemoteDesktop/LiquidGlassOverlay.swift'),
    relative_path: '../apps/psychosis-ios/PsychosisApp/Features/RemoteDesktop/LiquidGlassOverlay.swift',
    group_path: ['Features', 'RemoteDesktop'],
    name: 'LiquidGlassOverlay.swift'
  },
  {
    path: File.join(base_path, 'Features/RemoteDesktop/RemoteDesktopViewV2.swift'),
    relative_path: '../apps/psychosis-ios/PsychosisApp/Features/RemoteDesktop/RemoteDesktopViewV2.swift',
    group_path: ['Features', 'RemoteDesktop'],
    name: 'RemoteDesktopViewV2.swift'
  }
]

# Navigate to or create groups
def get_or_create_group(parent, path_components)
  current = parent
  path_components.each do |component|
    group = current.groups.find { |g| g.name == component }
    if group.nil?
      group = current.new_group(component)
      puts "Created group: #{component}"
    end
    current = group
  end
  current
end

# Add files
files_to_add.each do |file_info|
  file_path = file_info[:path]
  relative_path = file_info[:relative_path]
  group_path = file_info[:group_path]
  file_name = file_info[:name]
  
  # Check if file exists
  unless File.exist?(file_path)
    puts "⚠️  File not found: #{file_path}"
    next
  end
  
  # Navigate to group
  group = get_or_create_group(app_group, group_path)
  
  # Check if file already added
  existing_file = group.files.find { |f| f.path == file_name || f.path == relative_path || f.path == file_path }
  if existing_file
    puts "✅ Already added: #{file_name}"
    next
  end
    
  # Add file reference (use relative path like other files)
  file_ref = group.new_file(relative_path)
  
  # Add to target
  target.add_file_references([file_ref])
  
  puts "✅ Added: #{file_name}"
end

# Save project
project.save
puts ""
puts "✅ All files added to Xcode project!"
puts "Open the project and verify files are present."

