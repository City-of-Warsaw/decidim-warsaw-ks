# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/custom_proposals/version"

Gem::Specification.new do |s|
  s.version = Decidim::CustomProposals.version
  s.authors = [""]
  s.email = [""]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-custom_proposals"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-custom_proposals"
  s.summary = "A decidim custom_proposals module"
  s.description = "Component for comments for document."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", '0.29.3'
  s.add_dependency "decidim-core", '0.29.3'
  s.add_dependency "decidim-participatory_processes", '0.29.3'
end
