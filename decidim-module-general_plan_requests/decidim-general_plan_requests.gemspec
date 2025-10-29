# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/general_plan_requests/version"

Gem::Specification.new do |s|
  s.version = Decidim::GeneralPlanRequests.version
  s.authors = [""]
  s.email = [""]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-general_plan_requests"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-general_plan_requests"
  s.summary = "A decidim general_plan_requests module"
  s.description = "Component for adding general plan requests."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", '0.29.3'
  s.add_dependency "decidim-core", '0.29.3'
  s.add_dependency "decidim-participatory_processes", '0.29.3'
end
