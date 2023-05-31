# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/study_notes/version"

Gem::Specification.new do |s|
  s.version = Decidim::StudyNotes.version
  s.authors = [""]
  s.email = [""]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-study_notes"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-study_notes"
  s.summary = "A decidim study_notes module"
  s.description = "Component for marks for study on map."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", '0.24.3'
  s.add_dependency "decidim-core", '0.24.3'
  s.add_dependency "decidim-participatory_processes", '0.24.3'
end
