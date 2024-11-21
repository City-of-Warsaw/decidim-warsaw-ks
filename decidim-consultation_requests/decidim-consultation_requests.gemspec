# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/consultation_requests/version"

Gem::Specification.new do |s|
  s.version = Decidim::ConsultationRequests.version
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-consultation_requests"
  s.required_ruby_version = ">= 2.7"
  s.authors = [""]
  s.email = []
  s.name = "decidim-consultation_requests"
  s.summary = "A decidim consultation_requests module"
  s.description = "Module for managing requests for consultations."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", '0.24.3'
end
