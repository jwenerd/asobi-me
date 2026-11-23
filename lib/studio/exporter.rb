# frozen_string_literal: true

require "fileutils"
require "asobi"

module Studio
  # Evaluates any standard asobi sketch headlessly and writes SVG and/or
  # standalone HTML files into exports/<slug>/.
  module Exporter
    Result = Data.define(:slug, :sketch_path, :outputs)

    module_function

    def export(sketch_path, out_root: File.expand_path("../../exports", __dir__), at: nil, svg_still: true)
      path = File.expand_path(sketch_path)
      raise ArgumentError, "Sketch not found: #{path}" unless File.file?(path)

      slug = slug_for(path)
      out_dir = File.join(out_root, slug)
      FileUtils.mkdir_p(out_dir)

      previous_live = ENV["ASOBI_LIVE"]
      ENV["ASOBI_LIVE"] = "0"

      reel = Asobi::Sketch.evaluate(path)
      if reel.is_a?(Hash) && reel["error"]
        raise "Sketch error in #{path}: #{reel["error"]}"
      end

      shown = Asobi::Sketch.shown
      raise "Sketch #{path} did not call `show`" unless shown

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

      Result.new(slug:, sketch_path: path, outputs:)
    ensure
      ENV["ASOBI_LIVE"] = previous_live
    end

    def slug_for(path)
      dir = File.basename(File.dirname(path))
      base = File.basename(path, ".rb")
      base == "sketch" ? dir : base
    end
  end
end
