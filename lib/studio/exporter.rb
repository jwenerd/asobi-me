# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "time"
require "asobi"

module Studio
  # Evaluates any standard asobi sketch headlessly and writes SVG and/or
  # standalone HTML files into exports/<slug>/, with per-sketch digest caching.
  module Exporter
    META_FILENAME = ".export-meta.json"
    CACHE_VERSION = "v1"
    ROOT = File.expand_path("../..", __dir__)

    Result = Data.define(:slug, :sketch_path, :outputs, :cached)

    module_function

    def export(sketch_path, out_root: File.expand_path("../../exports", __dir__), at: nil, svg_still: true, force: false)
      path = File.expand_path(sketch_path)
      raise ArgumentError, "Sketch not found: #{path}" unless File.file?(path)

      slug = slug_for(path)
      out_dir = File.join(out_root, slug)
      FileUtils.mkdir_p(out_dir)

      digest = fingerprint(path, at:, svg_still:)
      meta_path = File.join(out_dir, META_FILENAME)

      if !force && (cached_outputs = read_valid_cache(meta_path, out_dir, digest))
        return Result.new(slug:, sketch_path: path, outputs: cached_outputs, cached: true)
      end

      previous_live = ENV["ASOBI_LIVE"]
      ENV["ASOBI_LIVE"] = "0"

      reel = Asobi::Sketch.evaluate(path)
      if reel.is_a?(Hash) && reel["error"]
        raise "Sketch error in #{path}: #{reel["error"]}"
      end

      shown = Asobi::Sketch.shown
      raise "Sketch #{path} did not call `show`" unless shown

      # Clear previous primary outputs before writing fresh ones so switching
      # between static and motion sketches does not leave stale files behind.
      if at.nil?
        [File.join(out_dir, "#{slug}.html"), File.join(out_dir, "#{slug}.svg")].each do |old|
          FileUtils.rm_f(old)
        end
      end

      outputs = []
      svg_opts = { on: shown.on, paper: shown.paper, grain: shown.grain }.compact
      is_motion = Asobi::Reel.motion?(shown.thing)
      is_interactive = reel.is_a?(Hash) && (reel.key?("parts") || !Asobi::Sketch.song.nil?)

      if is_motion || is_interactive
        html_path = File.join(out_dir, "#{slug}.html")
        Asobi::Reel.save(shown.thing, html_path, **shown.options, song: Asobi::Sketch.song)
        outputs << html_path
      end

      if !is_motion
        svg_path = File.join(out_dir, "#{slug}.svg")
        shown.thing.save(svg_path, **svg_opts)
        outputs << svg_path
      elsif svg_still || !at.nil?
        frame_time = at.nil? ? 0 : at.to_f
        suffix = at.nil? ? "" : "_at_#{format('%.2f', frame_time)}s"
        svg_path = File.join(out_dir, "#{slug}#{suffix}.svg")
        shown.thing.at(frame_time).save(svg_path, **svg_opts)
        outputs << svg_path
      end

      write_cache_meta(meta_path, digest, outputs)

      Result.new(slug:, sketch_path: path, outputs:, cached: false)
    ensure
      ENV["ASOBI_LIVE"] = previous_live
    end

    def prune!(valid_slugs:, out_root: File.expand_path("../../exports", __dir__))
      return [] unless Dir.exist?(out_root)

      valid = valid_slugs.map(&:to_s)
      removed = []

      Dir.children(out_root).sort.each do |entry|
        next if entry.start_with?(".")

        full_path = File.join(out_root, entry)
        next unless File.directory?(full_path)
        next if valid.include?(entry)

        FileUtils.rm_rf(full_path)
        removed << entry
      end

      removed
    end

    def fingerprint(sketch_path, at: nil, svg_still: true)
      sha = Digest::SHA256.new
      sha.update("#{CACHE_VERSION}|at=#{at.nil? ? 'nil' : format('%.6f', at.to_f)}|svg_still=#{svg_still}\n")

      sketch_dir = File.dirname(File.expand_path(sketch_path))
      files = []

      lockfile = File.join(ROOT, "Gemfile.lock")
      files << lockfile if File.file?(lockfile)

      files.concat(Dir.glob(File.join(ROOT, "lib", "**", "*.rb")))
      files.concat(
        Dir.glob(File.join(ROOT, "assets", "**", "*")).select do |f|
          File.file?(f) && !%w[.gitkeep .DS_Store].include?(File.basename(f))
        end
      )
      files.concat(
        Dir.glob(File.join(sketch_dir, "**", "*")).select do |f|
          File.file?(f) && !%w[SPEC.md .DS_Store].include?(File.basename(f))
        end
      )

      files.uniq.sort.each do |file|
        rel = file.sub("#{ROOT}/", "")
        sha.update(rel)
        sha.update("\0")
        sha.file(file)
        sha.update("\0")
      end

      sha.hexdigest
    end

    def read_valid_cache(meta_path, out_dir, expected_digest)
      return nil unless File.file?(meta_path)

      meta = JSON.parse(File.read(meta_path, encoding: "UTF-8"))
      return nil unless meta["digest"] == expected_digest

      names = meta["outputs"]
      return nil unless names.is_a?(Array) && !names.empty?

      paths = names.map { |name| File.join(out_dir, name) }
      paths.all? { |p| File.file?(p) } ? paths : nil
    rescue JSON::ParserError
      nil
    end

    def write_cache_meta(meta_path, digest, outputs)
      payload = {
        "version" => CACHE_VERSION,
        "digest" => digest,
        "outputs" => outputs.map { |p| File.basename(p) },
        "exported_at" => Time.now.utc.iso8601
      }
      File.write(meta_path, "#{JSON.pretty_generate(payload)}\n", encoding: "UTF-8")
    end

    def slug_for(path)
      dir = File.basename(File.dirname(path))
      base = File.basename(path, ".rb")
      base == "sketch" ? dir : base
    end
  end
end
