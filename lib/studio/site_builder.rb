# frozen_string_literal: true

require "cgi"
require "erb"
require "fileutils"
require "time"

module Studio
  # Assembles a self-contained static gallery site in `_site/` from
  # `sketches/<slug>/{sketch.rb,SPEC.md}` and exported assets in `exports/<slug>/`.
  module SiteBuilder
    SketchEntry = Data.define(
      :slug,
      :title,
      :category,
      :created,
      :status,
      :canvas_width,
      :canvas_height,
      :concept,
      :spec_markdown,
      :source_code,
      :has_html,
      :has_svg,
      :html_size_kb,
      :svg_size_kb
    ) do
      def portrait?
        canvas_width && canvas_height && canvas_height > canvas_width
      end

      def aspect_ratio_css
        return "1 / 1" unless canvas_width && canvas_height

        "#{canvas_width} / #{canvas_height}"
      end

      def kind_label
        has_html ? "Animated" : "Static SVG"
      end
    end

    BuildResult = Data.define(:out_dir, :entries)

    module_function

    def build(
      out_dir: Studio::SITE_DIR,
      sketches_dir: Studio::SKETCHES_DIR,
      exports_dir: Studio::EXPORTS_DIR,
      templates_dir: File.join(Studio::TEMPLATES_DIR, "site")
    )
      sketch_paths = Dir.glob(File.join(sketches_dir, "*", "sketch.rb")).sort
      entries = sketch_paths.map { |path| load_entry(path, exports_dir:) }
      entries.sort_by! { |e| [e.created || "", e.slug] }
      entries.reverse!

      FileUtils.rm_rf(out_dir)
      FileUtils.mkdir_p(File.join(out_dir, "assets"))
      FileUtils.mkdir_p(File.join(out_dir, "sketches"))

      # Prevent GitHub Pages from running Jekyll on the pre-built site.
      File.write(File.join(out_dir, ".nojekyll"), "", encoding: "UTF-8")

      # Copy stylesheet
      FileUtils.cp(
        File.join(templates_dir, "style.css"),
        File.join(out_dir, "assets", "style.css")
      )

      built_at = Time.now.utc.strftime("%Y-%m-%d %H:%M UTC")
      categories = entries.map(&:category).uniq.sort

      # Render gallery index
      index_html = render_template(
        File.join(templates_dir, "index.html.erb"),
        entries:,
        categories:,
        built_at:
      )
      File.write(File.join(out_dir, "index.html"), index_html, encoding: "UTF-8")

      # Copy per-sketch assets and render viewer shell pages
      entries.each_with_index do |entry, idx|
        dest_dir = File.join(out_dir, "sketches", entry.slug)
        FileUtils.mkdir_p(dest_dir)

        export_dir = File.join(exports_dir, entry.slug)
        svg_src = File.join(export_dir, "#{entry.slug}.svg")
        html_src = File.join(export_dir, "#{entry.slug}.html")

        FileUtils.cp(svg_src, File.join(dest_dir, "preview.svg")) if entry.has_svg
        write_gallery_html(html_src, File.join(dest_dir, "art.html")) if entry.has_html

        prev_entry = idx.positive? ? entries[idx - 1] : nil
        next_entry = idx < entries.length - 1 ? entries[idx + 1] : nil

        page_html = render_template(
          File.join(templates_dir, "sketch.html.erb"),
          entry:,
          prev_entry:,
          next_entry:,
          built_at:
        )
        File.write(File.join(dest_dir, "index.html"), page_html, encoding: "UTF-8")
      end

      BuildResult.new(out_dir:, entries:)
    end

    def load_entry(sketch_path, exports_dir:)
      sketch_dir = File.dirname(sketch_path)
      slug = Studio::Exporter.slug_for(sketch_path)
      spec_path = File.join(sketch_dir, "SPEC.md")

      spec_text = File.file?(spec_path) ? File.read(spec_path, encoding: "UTF-8") : ""
      source_code = File.read(sketch_path, encoding: "UTF-8")
      meta = parse_spec(spec_text, slug:)

      export_dir = File.join(exports_dir, slug)
      svg_path = File.join(export_dir, "#{slug}.svg")
      html_path = File.join(export_dir, "#{slug}.html")

      has_svg = File.file?(svg_path)
      has_html = File.file?(html_path)

      unless has_svg || has_html
        raise "Missing exported files for '#{slug}' in #{export_dir}. Run `bin/export` first."
      end

      SketchEntry.new(
        slug:,
        title: meta[:title],
        category: meta[:category],
        created: meta[:created],
        status: meta[:status],
        canvas_width: meta[:canvas_width],
        canvas_height: meta[:canvas_height],
        concept: meta[:concept],
        spec_markdown: spec_text,
        source_code:,
        has_html:,
        has_svg:,
        html_size_kb: has_html ? (File.size(html_path) / 1024.0).round(1) : nil,
        svg_size_kb: has_svg ? (File.size(svg_path) / 1024.0).round(1) : nil
      )
    end

    def parse_spec(spec_text, slug:)
      title = spec_text[/^#\s+(.+)$/, 1]&.strip || slug.split("-").map(&:capitalize).join(" ")
      category = spec_text[/^-\s+\*\*Category\*\*:\s*`?([^`\n]+)`?/i, 1]&.strip&.downcase || "sketch"
      created = spec_text[/^-\s+\*\*Created\*\*:\s*(\d{4}-\d{2}-\d{2})/i, 1]
      status = spec_text[/^-\s+\*\*Status\*\*:\s*`?([^`\n]+)`?/i, 1]&.strip

      canvas_match = spec_text.match(/^-\s+\*\*Canvas(?:\s*\/\s*Paper)?\*\*:\s*.*?\[(\d+)\s*,\s*(\d+)\]/i)
      canvas_width = canvas_match ? canvas_match[1].to_i : nil
      canvas_height = canvas_match ? canvas_match[2].to_i : nil

      concept_block = spec_text[/^##\s+Concept\s*\n+(.+?)(?=\n##\s+|\z)/m, 1]&.strip || ""
      concept = strip_markdown(concept_block.split(/\n\s*\n/).first.to_s)

      {
        title:,
        category:,
        created:,
        status:,
        canvas_width:,
        canvas_height:,
        concept:
      }
    end

    PLAYER_MOUNT_PATTERN = 'AsobiPlayer.mount(document.getElementById("stage")).update('
    PLAYER_MOUNT_GALLERY = 'AsobiPlayer.mount(document.getElementById("stage"), { controls: false, keys: false }).update('

    def write_gallery_html(src_path, dest_path)
      html = File.read(src_path, encoding: "UTF-8")
      unless html.include?(PLAYER_MOUNT_PATTERN)
        raise "Expected asobi player mount call not found in #{src_path}"
      end

      patched = html.sub(PLAYER_MOUNT_PATTERN, PLAYER_MOUNT_GALLERY)
      File.write(dest_path, patched, encoding: "UTF-8")
    end

    def strip_markdown(text)
      text
        .gsub(/\[([^\]]+)\]\([^)]+\)/, '\1')
        .gsub(/`([^`]+)`/, '\1')
        .gsub(/\*\*([^*]+)\*\*/, '\1')
        .gsub(/\*([^*]+)\*/, '\1')
        .gsub(/\s+/, " ")
        .strip
    end

    def render_template(template_path, **locals)
      context = TemplateContext.new(locals)
      template = File.read(template_path, encoding: "UTF-8")
      ERB.new(template, trim_mode: "-").result(context.get_binding)
    end

    # Clean binding scope for ERB templates with HTML escaping helper.
    class TemplateContext
      def initialize(locals)
        locals.each do |key, value|
          define_singleton_method(key) { value }
        end
      end

      def h(value)
        CGI.escapeHTML(value.to_s)
      end

      def get_binding
        binding
      end
    end
  end
end
