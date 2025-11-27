#!/usr/bin/env ruby
# Fix VNC file paths in Xcode project
# The paths are being resolved incorrectly - fix them

require 'xcodeproj'

project_path = File.expand_path('../../Psychosis/Psychosis.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

target = project.targets.first
puts "Target: #{target.name}"

# Files to fix
files_to_fix = {
  'VNCConnection.swift' => 'apps/psychosis-ios/PsychosisApp/Core/VNC/VNCConnection.swift',
  'VNCFrameBuffer.swift' => 'apps/psychosis-ios/PsychosisApp/Core/VNC/VNCFrameBuffer.swift',
  'CursorPaneController.swift' => 'apps/psychosis-ios/PsychosisApp/Core/Services/CursorPaneController.swift',
  'NativeVNCView.swift' => 'apps/psychosis-ios/PsychosisApp/Features/RemoteDesktop/NativeVNCView.swift',
  'LiquidGlassOverlay.swift' => 'apps/psychosis-ios/PsychosisApp/Features/RemoteDesktop/LiquidGlassOverlay.swift',
  'RemoteDesktopViewV2.swift' => 'apps/psychosis-ios/PsychosisApp/Features/RemoteDesktop/RemoteDesktopViewV2.swift'
}

# Find and fix each file reference
project.files.each do |file_ref|
  next unless file_ref.path
  
  file_name = File.basename(file_ref.path)
  if files_to_fix.key?(file_name)
    new_path = files_to_fix[file_name]
    
    # Check if path needs fixing
    if file_ref.path.include?('apps/psychosis-ios/apps/psychosis-ios') || 
       file_ref.path != new_path
      
      puts "Fixing: #{file_name}"
      puts "  Old: #{file_ref.path}"
      puts "  New: #{new_path}"
      
      file_ref.path = new_path
    else
      puts "✅ Already correct: #{file_name}"
    end
  end
end

project.save
puts ""
puts "✅ File paths fixed!"


