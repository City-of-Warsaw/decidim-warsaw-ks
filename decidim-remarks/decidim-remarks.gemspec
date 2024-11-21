# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/remarks/version"

Gem::Specification.new do |s|
  s.version = Decidim::Remarks.version
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-remarks"
  s.required_ruby_version = ">= 2.7"
  s.authors = [""]
  s.email = []
  s.name = "decidim-remarks"
  s.summary = "A decidim remarks module"
  s.description = "Component for adding Remarks."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-admin", '0.24.3'
  s.add_dependency "decidim-core", '0.24.3'
  s.add_dependency "decidim-participatory_processes", '0.24.3'
end
