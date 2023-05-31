# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/rest_api/version"

Gem::Specification.new do |s|
  s.version = Decidim::RestApi.version
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-rest_api"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-rest_api"
  s.summary = "A decidim rest_api module"
  s.description = "Rest API for consultations."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", '0.24.3'
  s.add_dependency "active_model_serializers"
  s.add_dependency "apipie-rails"
end
