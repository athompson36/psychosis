#!/usr/bin/env ruby
# Fix VNC file paths using absolute paths to avoid resolution issues

require 'xcodeproj'

project_path = File.expand_path('../../Psychosis/Psychosis.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

# Files to fix with their absolute paths
files_to_fix = {
  'VNCConnection.swift' => File.expand_path('PsychosisApp/Core/VNC/VNCConnection.swift', __dir__),
  'VNCFrameBuffer.swift' => File.expand_path('PsychosisApp/Core/VNC/VNCFrameBuffer.swift', __dir__),
  'CursorPaneController.swift' => File.expand_path('PsychosisApp/Core/Services/CursorPaneController.swift', __dir__),
  'NativeVNCView.swift' => File.expand_path('PsychosisApp/Features/RemoteDesktop/NativeVNCView.swift', __dir__),
  'LiquidGlassOverlay.swift' => File.expand_path('PsychosisApp/Features/RemoteDesktop/LiquidGlassOverlay.swift', __dir__),
  'RemoteDesktopViewV2.swift' => File.expand_path('PsychosisApp/Features/RemoteDesktop/RemoteDesktopViewV2.swift', __dir__)
}

puts "Fixing VNC file paths using absolute paths..."
puts "Project: #{project_path}\n"

fixed_count = 0

project.files.each do |file_ref|
  next unless file_ref.path
  
  file_name = File.basename(file_ref.path)
  if files_to_fix.key?(file_name)
    absolute_path = files_to_fix[file_name]
    
    # Verify file exists
    unless File.exist?(absolute_path)
      puts "❌ File not found: #{absolute_path}"
      next
    end
    
    # Set absolute path
    puts "Fixing: #{file_name}"
    puts "  Current: #{file_ref.path}"
    puts "  Absolute: #{absolute_path}"
    
    file_ref.path = absolute_path
    file_ref.source_tree = '<absolute>'
    
    fixed_count += 1
  end
end

if fixed_count > 0
  project.save
  puts "\n✅ Fixed #{fixed_count} file paths using absolute paths"
else
  puts "\n⚠️  No files needed fixing"
end


