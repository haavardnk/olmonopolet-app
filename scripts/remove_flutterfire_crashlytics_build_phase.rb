#!/usr/bin/env ruby

require "xcodeproj"

project_path = ARGV.fetch(0)
phase_name = 'FlutterFire: "flutterfire upload-crashlytics-symbols"'
project = Xcodeproj::Project.open(project_path)
removed_count = 0

project.targets.each do |target|
  target.shell_script_build_phases.each do |phase|
    next unless phase.name == phase_name

    phase.remove_from_project
    removed_count += 1
  end
end

project.save if removed_count.positive?

puts "Removed #{removed_count} FlutterFire Crashlytics build phase(s)"