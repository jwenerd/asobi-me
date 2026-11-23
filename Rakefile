# frozen_string_literal: true

require_relative "lib/studio"

def resolve_sketch(slug_or_path)
  return slug_or_path if File.file?(slug_or_path)

  candidate = File.join(Studio::SKETCHES_DIR, slug_or_path, "sketch.rb")
  return candidate if File.file?(candidate)

  abort "Could not find sketch '#{slug_or_path}'. Run `rake list` to see available sketches."
end

desc "List all sketches in sketches/"
task :list do
  sketches = Dir.glob(File.join(Studio::SKETCHES_DIR, "*", "sketch.rb")).sort
  if sketches.empty?
    puts "No sketches yet. Create one with: bin/new-sketch my-piece"
  else
    sketches.each do |path|
      slug = File.basename(File.dirname(path))
      spec = File.join(File.dirname(path), "SPEC.md")
      status = File.file?(spec) ? "SPEC.md" : "no spec"
      puts format("  %-30s (%s)  %s", slug, status, path.sub("#{Studio::ROOT}/", ""))
    end
  end
end

desc "Scaffold a new sketch: rake 'new[slug,type]' (type: generative|object|interactive)"
task :new, [:slug, :type] do |_t, args|
  abort "Usage: bundle exec rake 'new[my-sketch,generative]'" if args[:slug].to_s.empty?

  cmd = [File.join(Studio::ROOT, "bin", "new-sketch"), args[:slug]]
  cmd += ["--type", args[:type]] unless args[:type].to_s.empty?
  sh(*cmd)
end

desc "Run live browser preview: rake 'live[slug]'"
task :live, [:slug] do |_t, args|
  abort "Usage: bundle exec rake 'live[01-generative-bloom]'" if args[:slug].to_s.empty?

  sh(File.join(Studio::ROOT, "bin", "live"), args[:slug])
end

desc "Export one sketch or all sketches to exports/: rake export or rake 'export[slug]'"
task :export, [:slug] do |_t, args|
  cmd = [File.join(Studio::ROOT, "bin", "export")]
  cmd << args[:slug] unless args[:slug].to_s.empty?
  sh(*cmd)
end

namespace :media do
  desc "Convert a recording to MP4 via ffmpeg: rake 'media:mp4[path/to/clip.webm]'"
  task :mp4, [:input] do |_t, args|
    abort "Usage: bundle exec rake 'media:mp4[recording.webm]'" if args[:input].to_s.empty?

    sh(File.join(Studio::ROOT, "bin", "convert-video"), args[:input], "--mp4")
  end

  desc "Convert a recording to palette-optimized GIF via ffmpeg: rake 'media:gif[path/to/clip.webm]'"
  task :gif, [:input] do |_t, args|
    abort "Usage: bundle exec rake 'media:gif[recording.webm]'" if args[:input].to_s.empty?

    sh(File.join(Studio::ROOT, "bin", "convert-video"), args[:input], "--gif")
  end
end

task default: :list
