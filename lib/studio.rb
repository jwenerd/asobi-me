# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)

require "asobi"
require "studio/palettes"
require "studio/exporter"
require "studio/site_builder"

module Studio
  ROOT = File.expand_path("..", __dir__)
  SKETCHES_DIR = File.join(ROOT, "sketches")
  EXPORTS_DIR = File.join(ROOT, "exports")
  ASSETS_DIR = File.join(ROOT, "assets")
  TEMPLATES_DIR = File.join(ROOT, "templates")
  SITE_DIR = File.join(ROOT, "_site")
end
