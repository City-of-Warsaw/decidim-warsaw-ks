# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/consultation_map/version"

Gem::Specification.new do |s|
  s.version = Decidim::ConsultationMap.version
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-consultation_map"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-consultation_map"
  s.summary = "A decidim consultation_map component"
  s.description = "Component that allows to build a map for Participatory Space and allows users to add remarks on it."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", '0.24.3'
  s.add_dependency "decidim-core", '0.24.3'
  s.add_dependency "decidim-participatory_processes", '0.24.3'
end
