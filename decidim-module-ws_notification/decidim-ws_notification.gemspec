# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/ws_notification/version"

Gem::Specification.new do |s|
  s.version = Decidim::WsNotification.version
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-ws_notification"
  s.required_ruby_version = ">= 2.7"
  s.authors = [""]
  s.email = []
  s.name = "decidim-ws_notification"
  s.summary = "A decidim ws_notification module for Warszawski System Powiadomien"
  s.description = "."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", '0.24.3'
  s.add_dependency "savon", '2.12.0'
end
