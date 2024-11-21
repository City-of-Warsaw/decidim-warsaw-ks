# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/repository/version"

Gem::Specification.new do |s|
  s.version = Decidim::Repository.version
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-repository"
  s.required_ruby_version = ">= 2.7"
  s.authors = [""]
  s.email = []
  s.name = "decidim-repository"
  s.summary = "A decidim repository module"
  s.description = "Repository for files and images gallery."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", '0.24.3'
end
